local Players = game:GetService("Players");

local UserInputService = game:GetService("UserInputService");

local RunService = game:GetService("RunService");

local camera = workspace.CurrentCamera;

local player = Players.LocalPlayer;

local currentRotation = CFrame.new();

local deviceGravity = Vector3.new(0, 0, 0);

local function setupGyroCamera(character)

	wait();

	game.Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson;

	local Head: BasePart;

	

	if character:WaitForChild("Head") then

		Head = character:WaitForChild("Head");

	else

		return;

	end

	

	if (UserInputService.AccelerometerEnabled and UserInputService.GyroscopeEnabled) then

		local rotationConnection = UserInputService.DeviceRotationChanged:Connect(function(rotationVector, cframe)

			local x, y, z = cframe:ToOrientation();

			currentRotation = CFrame.Angles(rotationVector.Position.X, rotationVector.Position.Y, rotationVector.Position.Z) * CFrame.Angles(math.rad(-90), 0, 0);

		end);

		local gravityConnection = UserInputService.DeviceGravityChanged:Connect(function(gravityInput)

			deviceGravity = gravityInput.Position;

		end);

		local renderConnection = RunService.RenderStepped:Connect(function()

			if (camera.CameraType ~= Enum.CameraType.Scriptable) then

				camera.CameraType = Enum.CameraType.Scriptable;

			end

			local targetPosition = Head.CFrame;

			local offset = CFrame.new(0, 0, 0);

			camera.CFrame = CFrame.new((targetPosition * CFrame.new(0, 0, -0.65)).Position) * currentRotation * offset;

		end);

		character.Humanoid.Died:Connect(function()

			rotationConnection:Disconnect();

			gravityConnection:Disconnect();

			renderConnection:Disconnect();

			camera.CameraType = Enum.CameraType.Custom;

		end);

	end

end

if player.Character then

	task.spawn(setupGyroCamera, player.Character);

end

player.CharacterAdded:Connect(setupGyroCamera);



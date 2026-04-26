WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

Push = require("push")

LARGE_FONT = love.graphics.newFont(32)
SMALL_FONT = love.graphics.newFont(16)
PADDLE_WIDTH = 8
PADDLE_HEIGHT = 32
PADDLE_SPEED = VIRTUAL_HEIGHT / 2
BALL_SIZE = 4

Player1Score = 0
Player2Score = 0

Player1 = {
	x = 10,
	y = 10,
}

Player2 = {
	x = VIRTUAL_WIDTH - PADDLE_WIDTH - 10,
	y = VIRTUAL_HEIGHT - 42,
}

Ball = {
	x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2,
	y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2,
	dx = 0,
	dy = 0,
}

GameState = "title"

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.window.setTitle("Pong")
	Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
	})
end

function love.update(dt)
	UpdatePlayers(dt)

	-- ball
	if GameState == "play" then
		UpdateBall(dt)
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if GameState == "title" then
		if key == "enter" or key == "return" then
			GameState = "serve"
		end
	elseif GameState == "serve" then
		GameState = "play"

		-- give ball initial momentum
		Ball.dx = 60 + math.random(30)
		Ball.dy = 15 + math.random(80)
		Ball.dx = math.random(2) == 1 and Ball.dx or -Ball.dx
		Ball.dy = math.random(2) == 1 and Ball.dy or -Ball.dy
	elseif GameState == "end" then
		if key == "enter" then
			Player1Score = 0
			Player2Score = 0
			GameState = "title"
		end
	end
end

function love.draw()
	Push:start()
	love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
	love.graphics.setFont(LARGE_FONT)

	if GameState == "title" then
		DrawTitle()
	elseif GameState == "serve" then
		DrawServeText()
	elseif GameState == "end" then
		DrawWinner()
	end

	PrintScores()
	DrawPaddles()
	DrawBall()
	Push:finish()
end

function UpdateBall(dt)
	Ball.x = Ball.x + Ball.dx * dt
	Ball.y = Ball.y + Ball.dy * dt

	-- bounce off walls
	if Ball.y <= 0 then
		Ball.dy = -Ball.dy * 1.02
	elseif Ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
		Ball.dy = -Ball.dy * 1.02
	end

	-- bounce off paddles
	if Collides(Ball, Player1) then
		Ball.x = Player1.x + PADDLE_WIDTH
		Ball.dx = -Ball.dx * 1.05
	elseif Collides(Ball, Player2) then
		Ball.x = Player2.x - BALL_SIZE
		Ball.dx = -Ball.dx * 1.05
	end

	-- reset ball if out of bounds
	if Ball.x < 0 or Ball.x > VIRTUAL_WIDTH - BALL_SIZE then
		if Ball.x < 0 then
			Player2Score = Player2Score + 1
		end
		if Ball.x > VIRTUAL_WIDTH - BALL_SIZE then
			Player1Score = Player1Score + 1
		end

		Ball.x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2
		Ball.y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2
		Ball.dx = 0
		Ball.dy = 0

		if Player1Score >= 10 or Player2Score >= 10 then
			GameState = "end"
		else
			GameState = "serve"
		end
	end
end

function Collides(b, p)
	return not (b.x > p.x + PADDLE_WIDTH or p.x > b.x + BALL_SIZE or b.y > p.y + PADDLE_HEIGHT or p.y > b.y + BALL_SIZE)
end

function UpdatePlayers(dt)
	-- player1
	if love.keyboard.isDown("w") then
		Player1.y = Player1.y - PADDLE_SPEED * dt
	elseif love.keyboard.isDown("s") then
		Player1.y = Player1.y + PADDLE_SPEED * dt
	end

	-- player2
	if love.keyboard.isDown("up") then
		Player2.y = Player2.y - PADDLE_SPEED * dt
	elseif love.keyboard.isDown("down") then
		Player2.y = Player2.y + PADDLE_SPEED * dt
	end
end

function DrawWinner()
	love.graphics.setFont(LARGE_FONT)
	local winner = Player1Score >= 10 and 1 or 2
	love.graphics.printf("Player " .. winner .. " wins!", 0, 10, VIRTUAL_WIDTH, "center")
	love.graphics.setFont(SMALL_FONT)
	love.graphics.printf("Press Enter to Restart", 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, "center")
end

function DrawServeText()
	love.graphics.setFont(SMALL_FONT)
	love.graphics.printf("Press Enter to Serve!", 0, VIRTUAL_HEIGHT / 2 - 60, VIRTUAL_WIDTH, "center")
end

function DrawTitle()
	love.graphics.setFont(LARGE_FONT)
	love.graphics.printf("Play Pong!", 0, 10, VIRTUAL_WIDTH, "center")
	love.graphics.setFont(SMALL_FONT)
	love.graphics.printf("Press Enter", 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, "center")
end

function DrawCenterLines()
	love.graphics.line(0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, VIRTUAL_HEIGHT / 2)
	love.graphics.line(VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)
end

function DrawPaddles()
	-- player1
	love.graphics.rectangle("fill", Player1.x, Player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)

	-- player2
	love.graphics.rectangle("fill", Player2.x, Player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)
end

function DrawBall()
	love.graphics.rectangle("fill", Ball.x, Ball.y, BALL_SIZE, BALL_SIZE)
end

function PrintScores()
	love.graphics.setFont(LARGE_FONT)
	love.graphics.print(Player1Score, VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT / 2 - 16)
	love.graphics.print(Player2Score, VIRTUAL_WIDTH / 2 + 10, VIRTUAL_HEIGHT / 2 - 16)
end

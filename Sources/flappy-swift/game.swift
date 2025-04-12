import Reactivity

enum GameStatus {
    case new
    case playing
    case gameOver
}

@Reactive
final class Game {
    private(set) var state: GameState

    private let gravity: Double = 0.001
    private let flapForce: Double = -0.3
    private let obstacleSpeed: Double = 0.1
    private let obstacleGap: Double = 150.0
    private let obstacleWidth: Double = 50.0
    private var lastFrame: Double?

    init() {
        self.state = GameState(
            bird: Bird(frame: Rect(x: 100, y: 300, width: 30, height: 30)),
            obstacles: [],
            score: 0,
            status: .new
        )
    }

    func start() {
        guard state.status == .new else { return }
        state.status = .playing
    }

    func flap() {
        guard state.status == .playing else { return }
        state.bird.velocity = flapForce
    }

    func reset() {
        lastFrame = nil
        state = GameState(
            bird: Bird(frame: Rect(x: 100, y: 300, width: 30, height: 30)),
            obstacles: [],
            score: 0,
            status: .new
        )
    }

    func animate(timestamp: Double) {
        guard let lastFrame = lastFrame else {
            lastFrame = timestamp
            return
        }
        self.lastFrame = timestamp

        guard state.status == .playing else { return }

        let delta = (timestamp - lastFrame)

        print("delta: \(delta)")

        // Update bird
        state.bird.velocity += gravity * delta
        state.bird.frame.y += state.bird.velocity * delta

        // Check for collisions with ground or ceiling
        if state.bird.frame.y <= 0 || state.bird.frame.y + state.bird.frame.height >= 600 {
            state.status = .gameOver
            return
        }

        // Update obstacles
        for (index, obstacle) in state.obstacles.enumerated() {
            state.obstacles[index].frame.x -= obstacleSpeed * delta

            // Check for collision with bird
            if checkCollision(bird: state.bird, obstacle: obstacle) {
                state.status = .gameOver
                return
            }

            // Check if bird passed obstacle
            if !obstacle.passed && obstacle.frame.x + obstacle.frame.width < state.bird.frame.x {
                state.obstacles[index].passed = true
                state.score += 1
            }
        }

        // Remove off-screen obstacles
        state.obstacles.removeAll { $0.frame.x < -obstacleWidth }

        // Add new obstacles
        if state.obstacles.isEmpty || state.obstacles.last!.frame.x < 400 {
            addObstacle()
        }
        print("obstacles: \(state.obstacles.count)")
    }

    private func addObstacle() {
        print("addObstacle")
        let gapPosition = Double.random(in: 100...400)
        let obstacle = Obstacle(
            frame: Rect(x: 800, y: 0, width: obstacleWidth, height: 600),
            gapPosition: gapPosition,
            gapSize: obstacleGap
        )
        state.obstacles.append(obstacle)
    }

    private func checkCollision(bird: Bird, obstacle: Obstacle) -> Bool {
        let topObstacleRect = Rect(
            x: obstacle.frame.x,
            y: 0,
            width: obstacle.frame.width,
            height: obstacle.gapPosition - obstacle.gapSize / 2
        )

        let bottomObstacleRect = Rect(
            x: obstacle.frame.x,
            y: obstacle.gapPosition + obstacle.gapSize / 2,
            width: obstacle.frame.width,
            height: 600 - (obstacle.gapPosition + obstacle.gapSize / 2)
        )

        return bird.frame.intersects(topObstacleRect) || bird.frame.intersects(bottomObstacleRect)
    }
}

struct Rect {
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    func intersects(_ other: Rect) -> Bool {
        x < other.x + other.width && x + width > other.x && y < other.y + other.height && y + height > other.y
    }
}

@Reactive
final class Bird {
    var frame: Rect
    var velocity: Double = 0.0

    init(frame: Rect) {
        self.frame = frame
    }
}

@Reactive
final class Obstacle {
    var frame: Rect
    var gapPosition: Double
    var gapSize: Double
    var passed: Bool = false

    init(frame: Rect, gapPosition: Double, gapSize: Double) {
        self.frame = frame
        self.gapPosition = gapPosition
        self.gapSize = gapSize
    }
}

struct GameState {
    var bird: Bird
    var obstacles: [Obstacle]
    var score: Int
    var status: GameStatus
}

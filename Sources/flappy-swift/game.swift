import Foundation
import Reactivity

@Reactive
final class Game {
    private(set) var state: GameState
    private(set) var mode: GameMode
    private(set) var score: Int

    @ReactiveIgnored
    private var lastFrame: Double?

    // Game dimensions
    let gameWidth = 800
    let gameHeight = 600

    private let gravity: Double = 0.0008
    private let flapForce: Double = -0.015
    private let obstacleSpeed: Double = 0.2
    private let obstacleGap: Double = 205.0
    private let obstacleWidth: Double = 40.0
    private let flapDecayRate: Double = 0.98
    private let maxUpwardVelocity: Double = -0.5

    init() {
        self.state = GameState()
        self.mode = .new
        self.score = 0
    }

    func start() {
        guard mode == .new else { return }
        mode = .playing
    }

    func flap() {
        guard mode == .playing else { return }
        state.bird.flapLift = 1.0
    }

    func reset() {
        lastFrame = nil
        state = GameState()
        mode = .playing
        score = 0
    }

    func animate(timestamp: Double) {
        guard let lastFrame = lastFrame else {
            lastFrame = timestamp
            return
        }
        self.lastFrame = timestamp

        guard mode == .playing else { return }

        let delta = timestamp - lastFrame

        // Update bird
        if state.bird.flapLift > 0.0 {
            let velocityFactor = max(0.0, min(1.0, (state.bird.velocity - maxUpwardVelocity) / -maxUpwardVelocity))
            state.bird.velocity += flapForce * state.bird.flapLift * velocityFactor * delta
            let decayFactor = 1.0 - (1.0 - flapDecayRate) * delta
            state.bird.flapLift *= decayFactor
            if state.bird.flapLift < 0.001 {
                state.bird.flapLift = 0.0
            }
        }

        state.bird.velocity += gravity * delta
        state.bird.frame.y += state.bird.velocity * delta

        // Check for collisions with ground or ceiling
        if state.bird.frame.y <= 0 || state.bird.frame.y + state.bird.frame.height >= Double(gameHeight) {
            mode = .gameOver
            return
        }

        // Update obstacles
        for obstacle in state.obstacles {
            // Move both parts of the obstacle
            obstacle.topFrame.x -= obstacleSpeed * delta
            obstacle.bottomFrame.x -= obstacleSpeed * delta

            if checkCollision(bird: state.bird, obstacle: obstacle) {
                mode = .gameOver
                return
            }

            if !obstacle.passed && obstacle.topFrame.x + obstacle.topFrame.width < state.bird.frame.x {
                obstacle.passed = true
                score += 1
            }
        }

        // Remove off-screen obstacles
        state.obstacles.removeAll { $0.topFrame.x < -obstacleWidth }

        // Add new obstacles
        if state.obstacles.isEmpty || state.obstacles.last!.topFrame.x < Double(gameWidth) / 2 {
            addObstacle()
        }
    }

    private func addObstacle() {
        let gapPosition = Double.random(in: obstacleGap...(Double(gameHeight) - obstacleGap))
        let obstacle = Obstacle(
            frame: Rect(x: Double(gameWidth), y: 0, width: obstacleWidth, height: Double(gameHeight)),
            gapPosition: gapPosition,
            gapSize: obstacleGap
        )
        state.obstacles.append(obstacle)
    }

    private func checkCollision(bird: Bird, obstacle: Obstacle) -> Bool {
        bird.frame.intersects(obstacle.topFrame) || bird.frame.intersects(obstacle.bottomFrame)
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
    fileprivate(set) var frame: Rect
    fileprivate(set) var velocity: Double = 0.0
    fileprivate(set) var flapLift: Double = 0.0

    init() {
        self.frame = Rect(x: 100, y: 300, width: 100, height: 90)
    }
}

@Reactive
final class Obstacle {
    fileprivate(set) var passed: Bool = false
    fileprivate(set) var topFrame: Rect
    fileprivate(set) var bottomFrame: Rect
    fileprivate(set) var topText: String
    fileprivate(set) var bottomText: String

    private static let swiftExpressions = [
        "isolated (any Actor)? = #isolation",
        "@MainActor func updateUI()",
        "var content: some HTML",
        "{ [weak self] in guard let self else { return } }",
        "if case .success(let value) = result { }",
        "for (index, element) in array.enumerated()",
        "array.filter { $0 > 5 }",
        "array.map { $0 * 2 }",
        "array.reduce(0, +)",
        "try! dangerousFunction()",
        "try? await Task.sleep(for: .seconds(1))",
        "@_exported import ElementaryDOM",
        "#if hasFeature(Embedded)",
        "#if canImport(FoundationEssentials)",
        "protocol Something: AnyObject",
        "nonisolated(unsafe) private(set) var value",
        "<each T>(_ item: repeat each T) -> (repeat each T)",
        "let range = 1...10",
        "fatalError(\"unexpected\")",
        "@Observable final class Model",
    ]

    init(frame: Rect, gapPosition: Double, gapSize: Double) {
        self.topFrame = Rect(
            x: frame.x,
            y: 0,
            width: frame.width,
            height: gapPosition - gapSize / 2
        )

        self.bottomFrame = Rect(
            x: frame.x,
            y: gapPosition + gapSize / 2,
            width: frame.width,
            height: frame.height - (gapPosition + gapSize / 2)
        )

        self.topText = Self.swiftExpressions.randomElement()!
        self.bottomText = Self.swiftExpressions.randomElement()!
    }
}

@Reactive
final class GameState {
    fileprivate(set) var bird: Bird
    fileprivate(set) var obstacles: [Obstacle]

    init() {
        self.bird = Bird()
        self.obstacles = []
    }
}

enum GameMode {
    case new
    case playing
    case gameOver
}

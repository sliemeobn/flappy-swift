import ElementaryCSS
import ElementaryDOM

@View
struct GameView {
    @State var game = Game()

    var content: some View {
        Block(
            .position(.relative),
            .width(.px(800)),
            .height(.px(600)),
            .background(.gray800)
        ) {
            GameStateView(game: game.state)

            // Start Game Overlay
            if game.state.status == .new {
                Block {
                    FlexColumn(align: .center, gap: 20) {
                        Paragraph(.fontSize(.xxl), .color(.white)) {
                            "Flappy Bird"
                        }
                        button {
                            "Start Game"
                        }
                        .style(
                            .background(.orange500),
                            .padding(y: 2, x: 6),
                            .borderRadius(1),
                            .color(.white)
                        )
                        .onClick { _ in
                            game.start()
                        }
                    }
                }
                .style(
                    .position(.absolute),
                    .inset(0),
                    .background(.black60a),
                    .display(.flex),
                    .alignItems(.center),
                    .justifyContent(.center)
                )
            } else if game.state.status == .gameOver {
                Block {
                    FlexColumn(align: .center, gap: 20) {
                        Paragraph(.fontSize(.xxl), .color(.white)) {
                            "Game Over!"
                        }
                        button {
                            "Play Again"
                        }
                        .style(
                            .background(.orange500),
                            .padding(y: 2, x: 6),
                            .borderRadius(1),
                            .color(.white)
                        )
                        .onClick { _ in
                            game.reset()
                        }
                    }
                }
                .style(
                    .position(.absolute),
                    .inset(0),
                    .background(.black60a),
                    .display(.flex),
                    .alignItems(.center),
                    .justifyContent(.center)
                )
            } else if game.state.status == .playing {
                EmptyHTML()
                    .receive(onAnimationFrame) { event in
                        game.animate(timestamp: event.timestamp)
                    }
            }
        }
        .receive(GlobalDocument.onKeyDown) { event in
            if event.key == " " {
                if game.state.status == .new {
                    game.start()
                } else if game.state.status == .playing {
                    game.flap()
                }
            }
        }

    }
}

@View
struct GameStateView {
    var game: GameState

    var content: some View {
        BirdView(bird: game.bird)

        ForEach(game.obstacles) { obstacle in
            ObstacleView(obstacle: obstacle)
        }

        ScoreView(score: game.score)
    }
}

@View
struct BirdView {
    let bird: Bird

    var content: some View {
        Block {
            // Empty content block
        }
        .style(
            .position(.absolute),
            .width(.px(Int(bird.frame.width))),
            .height(.px(Int(bird.frame.height))),
            .background(.yellow500),
            .inset(t: .px(Int(bird.frame.y)), l: .px(Int(bird.frame.x)))
        )
    }
}

@View
struct ObstacleView {
    let obstacle: Obstacle

    var content: some View {
        Block {
            // Empty content block
        }
        .style(
            .position(.absolute),
            .width(.px(Int(obstacle.frame.width))),
            .height(.px(Int(obstacle.gapPosition - obstacle.gapSize / 2))),
            .background(.green500),
            .inset(t: 0, l: .px(Int(obstacle.frame.x)))
        )

        Block {
            // Empty content block
        }
        .style(
            .position(.absolute),
            .width(.px(Int(obstacle.frame.width))),
            .height(.px(Int(600 - (obstacle.gapPosition + obstacle.gapSize / 2)))),
            .background(.green500),
            .inset(t: .px(Int(obstacle.gapPosition + obstacle.gapSize / 2)), l: .px(Int(obstacle.frame.x)))
        )
    }
}

@View
struct ScoreView {
    let score: Int

    var content: some View {
        Block {
            "Score: \(score)"
        }
        .style(
            .position(.absolute),
            .inset(t: 20, l: 20),
            .color(.white),
            .fontSize(.xl),
            .fontWeight(.bold)
        )
    }
}

extension CSSColor {
    static let black60a: Self = "#00000099"
    static let orange500: Self = "#F97316"
    static let green500: Self = "#10B981"
    static let yellow500: Self = "#F59E0B"
    static let gray800: Self = "#1F2937"
}

extension CSSFontSize {
    static let xs = CSSFontSize(.rem(0.75))
    static let lg = CSSFontSize(.rem(1.125))
    static let xl = CSSFontSize(.rem(1.25))
    static let xxl = CSSFontSize(.rem(1.5))
}

import ElementaryCSS
import ElementaryDOM

@View
struct AppView {
    var content: some View {
        FlexColumn(align: .center, gap: 8) {
            MainContent()
            Footer()
        }.style(
            .fontFamily(.monospace),
            .margin(t: 4)
        )
    }
}

@View
struct MainContent {
    @State var game = Game()

    var content: some View {
        Block(
            .position(.relative),
            .height(.px(game.gameHeight)),
            .minWidth(.px(game.gameHeight)),
            .width(.px(game.gameWidth)),
            .maxWidth(.px(game.gameWidth)),
            .overflow(.clip),
            .borderWidth(2),
            .borderStyle("double")
        ) {
            Block {
                GameView(game: game.state)
            }.style(
                .opacity(game.mode == .playing ? 1 : 0),
                .transition("opacity 0.3s ease-in")
            )

            GameModeOverlay(
                status: game.mode,
                score: game.score
            )
            .onClick({ _ in
                onInput()
            })

            Block {
                if game.mode == .playing {
                    EmptyHTML()
                        .receive(onAnimationFrame) { event in
                            game.animate(timestamp: event.timestamp)
                        }
                }
            }
        }
        .receive(GlobalDocument.onKeyDown) { event in
            if event.key.utf8Equals(" ") {
                onInput()
            }
        }
    }

    func onInput() {
        switch game.mode {
        case .new:
            game.start()
        case .playing:
            game.flap()
        case .gameOver:
            game.reset()
        }
    }
}

@View
struct GameView {
    var game: GameState

    var content: some View {
        BirdView(bird: game.bird)

        ForEach(game.obstacles) { obstacle in
            ObstacleView(obstacle: obstacle)
        }
    }
}

@View
struct GameModeOverlay {
    var status: GameMode
    var score: Int

    var isPlaying: Bool {
        status == .playing
    }

    var content: some View {
        Paragraph(.inset(t: 5, l: 5), .position(.absolute)) {
            "Score: \(score)"
        }.style(
            .transition("opacity 0.5s ease-in-out"),
            .opacity(status == .playing ? 1 : 0)
        )

        FlexColumn(align: .center) {
            Paragraph(
                .letterSpacing(isPlaying ? 0 : 3),
                .fontSize(isPlaying ? .px(30) : .px(50)),
                .borderColor(isPlaying ? .transparent : .orange),
                .padding(l: 3),
                .fontWeight(.bold),
                .color(.orange),
                .borderWidth(1),
                .borderStyle("dotted"),
                .textAlign(.center),
                .background(.backgroundTransparent),
                .transition("all 0.7s")
            ) {
                "FLAPPY SWIFT"
            }
        }.style(
            .position(.absolute),
            .inset(t: isPlaying ? 4 : 30, r: 0, b: .auto, l: 0),
            .transition("all 0.7s")
        )

        Block(.position(.absolute), .inset(0), .display(.flex)) {
            Paragraph(.margin(.auto), .fontSize(.lg), .textAlign(.center), .lineHeight(.em(2))) {
                switch status {
                case .new:
                    Text("press space or tap to start")
                        .style(.opacity(0.6))
                case .playing:
                    EmptyHTML()
                case .gameOver:
                    Text("GAME OVER")
                        .style(.fontSize(.xxl))

                    br()
                    Text("press space or tap to go again")
                        .style(.opacity(0.6))
                    br()
                    Text("FINAL SCORE: \(score)")
                }
            }
        }
    }
}
@View
struct BirdView {
    let bird: Bird

    var rotation: Double {
        min(max((bird.velocity * 100) - 15, -40), 50)
    }

    var content: some View {
        Block(
            .position(.absolute),
            .width(.px(Int(bird.frame.width))),
            .height(.px(Int(bird.frame.height))),
            .inset(t: .px(Int(bird.frame.y)), l: .px(Int(bird.frame.x))),
            .transform(.rotate(rotation)),
        ) {
            pre {
                ASCIIArt.bird
            }
            .style(
                .inset(t: -2, l: -4),
                .position(.relative),
                .fontWeight(.black),
                .color(.orange),
                .whiteSpace("pre"),
                .fontSize(.px(5)),
                .transform("scale(\(bird.frame.width / 70))"),
                .lineHeight("1"),
                .transformOrigin(.topLeft),
            )
        }
        // .style(
        //     .borderWidth(1),
        //     .borderColor(.orange)
        // )
    }
}

@View
struct ObstacleView {
    let obstacle: Obstacle

    var content: some View {
        Block(.display(.init(rawValue: "contents")), .fontFamily("'Arial Narrow', Arial, sans-serif"), .color(.purple)) {
            Part(text: obstacle.topText, frame: obstacle.topFrame, isTop: true)
            Part(text: obstacle.bottomText, frame: obstacle.bottomFrame, isTop: false)
        }
    }

    @View
    struct Part {
        let text: String
        let frame: Rect
        let isTop: Bool

        var content: some View {
            Paragraph {
                text
            }
            .style(
                .position(.absolute),
                .inset(t: .px(Int(frame.y)), l: .px(Int(frame.x))),
                .width(.px(Int(frame.width))),
                .height(.px(Int(frame.height))),
                .fontSize(.px(Int(frame.width))),
                .whiteSpace("nowrap"),
                .transform(.rotate(isTop ? 180 : 0))
            ).attributes(
                .style([
                    "writing-mode": "vertical-lr"
                ])
            )
        }
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
            .inset(t: 4, l: 4),
            .color(.white),
            .fontSize(.xl),
            .fontWeight(.bold)
        )
    }
}

@View
struct GameOverlay<Wrapped: View> {
    let wrapped: Wrapped

    init(@HTMLBuilder content: () -> Wrapped) {
        self.wrapped = content()
    }

    var content: some View {
        Block {
            wrapped
        }
        .style(
            .position(.absolute),
            .inset(0),
            .display(.flex),
            .alignItems(.center),
            .justifyContent(.center)
        )
    }
}

@View
struct Footer {
    var content: some View {
        Block(.fontSize(.sm), .color(.foreground), .opacity(0.6), .textAlign(.center), .lineHeight("1.5")) {
            Paragraph(.fontWeight(.bold)) {
                "A WebAssembly game written in Swift in ~100 KB."
            }
            Paragraph(.margin(t: 2)) {
                "This is a technical demo of ElementaryDOM and ElementaryCSS DOM-rendering performance."
            }
            Paragraph {
                "Go to "
                a(.href("https://github.com/sliemeobn/flappy-swift")) { "https://github.com/sliemeobn/flappy-swift" }
                    .style(.color(.orange))
                    .style(when: .hover, .textDecoration("underline"))

                " for the source code and more details."
            }
        }
    }
}

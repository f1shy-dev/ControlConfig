//
//  TutorialSheetView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 08/08/2023
//

import AVFoundation
import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
  }

  func makeUIView(context: Context) -> UIView {
    return LoopingPlayerUIView(frame: .zero)
  }
}

class LoopingPlayerUIView: UIView {
  private let playerViewController = AVPlayerViewController()
  private var playerLooper: AVPlayerLooper?

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    // Load the resource
    let fileUrl = Bundle.main.url(forResource: "cowlite-tutorial", withExtension: "mp4")!
    let asset = AVAsset(url: fileUrl)
    let item = AVPlayerItem(asset: asset)

    // Setup the player
    let player = AVQueuePlayer()
    playerViewController.player = player
    playerViewController.videoGravity = .resizeAspect
    playerViewController.showsPlaybackControls = true
    playerViewController.player?.isMuted = true
    playerViewController.allowsPictureInPicturePlayback = false
    addSubview(playerViewController.view)

    // Create a new player looper with the queue player and template item
    playerLooper = AVPlayerLooper(player: player, templateItem: item)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    playerViewController.view.frame = bounds
  }
}

struct Step {
  let title: String
  let description: String
  let view: AnyView?
}

struct TutorialSheetViewer: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  let steps: [Step]
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        ForEach(steps.indices, id: \.self) { index in
          let step = steps[index]
          HStack(alignment: .top) {
            Text("\(index + 1)")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.primary)
              .frame(width: 40, height: 40)
              .background(Color.accentColor.opacity(colorScheme == .dark ? 0.5 : 0.2))
              .cornerRadius(10)
              .padding(5)
            VStack(alignment: .leading, spacing: 5) {
              Text(step.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
              Text(.init(step.description))
                .font(.system(size: 15, weight: .regular)).foregroundColor(.gray)
              if let view = step.view {
                view.padding(.top, 4)
              }
            }.padding(.leading, 6)
            Spacer()
          }
        }
      }.padding([.all])
    }
  }
}




struct TutorialSheetView: View {
  @Environment(\.dismiss) var dismiss
  @State var exampleColor = Color.accentColor
  @State var exampleBlur = 72
  var body: some View {
      let c_or_m = activeExploit == .KFD ? "customisations": "modules"
      let  step_addcustoms_view = AnyView(
        HStack {

          Label {
            Text("Connectivity").foregroundColor(.primary)
          } icon: {
            Image(systemName: "wifi").foregroundColor(.accentColor)
          }

          Spacer()
          Button(action: {
            Haptic.shared.play(.light)
          }) {
            Image(systemName: "pencil").foregroundColor(.accentColor)
          }.buttonStyle(.bordered).clipShape(Capsule()).tint(.black)
        }.padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)).background(
          Material.thick
        ).cornerRadius(10).font(.system(size: 16)))

       let step_editcolors = Step(
          title: "Edit Colors",
          description:
            "If you want, you can change the colors of the control center in \"Edit CC Colors\".",
          view: AnyView(
            VStack {

              ColorPicker("Colour (with opacity)", selection: $exampleColor).padding(.bottom, 4)
              HStack {
                Text("Blur (\(exampleBlur))")
                Spacer()
                Slider(value: $exampleBlur.doubleBinding, in: 0...100, step: 1) {
                  Text("Blur")
                } minimumValueLabel: {
                  Text("0")
                } maximumValueLabel: {
                  Text("100")
                }.frame(width: 150)
              }
            }.padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)).background(
              Material.thick
            ).cornerRadius(10).font(.system(size: 16)))
       )
      
      
      let step_applytweaks =         Step(
        title: "Apply Tweaks",
        description:
            "**Hit Apply on the main page to apply all your \(c_or_m), colors\(activeExploit == .KFD ? " and also make your modules movable** (you don't have to have any \(c_or_m) added either)" : " and your modules' order**"), then respring!\(activeExploit == .KFD ? " If it doesn't work, try again, and also try Hybrid Apply (hold down on apply/respring buttons for extra options)" : "")",
        view: AnyView(
          HStack {
            Button(
              action: {
                Haptic.shared.play(.light)
              },
              label: {
                Label("Apply", systemImage: "seal")

              }
            ).contextMenu {
                if activeExploit == .KFD{
                    Button("Run Exploit (kopen)") { Haptic.shared.play(.light) }
                    Button("Hybrid Apply") { Haptic.shared.play(.light) }
                }
            }

            Spacer()

            Button(
              action: {
                Haptic.shared.play(.light)
              },
              label: {
                Label("Respring", systemImage: "arrow.triangle.2.circlepath.circle")
              }
            ).contextMenu {

              Button {
                Haptic.shared.play(.light)
              } label: {
                Label("Frontboard Respring", systemImage: "arrow.triangle.2.circlepath")
              }

              Button {
                Haptic.shared.play(.light)
              } label: {
                Label("Backboard Respring", systemImage: "arrow.2.squarepath")
              }

              Button {
                Haptic.shared.play(.light)
              } label: {
                Label("Legacy Respring", systemImage: "arrow.rectanglepath")
              }
            }
          }.padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)).background(
            Material.thick
          ).cornerRadius(10).font(.system(size: 16))
        )
      )
      
      let step_finished =         Step(title: "Finished!", description: "That's all to this tutorial - go and try out everything you just learnt, and have fun customising!", view: nil)


    return NavigationView {
        TutorialSheetViewer(steps: activeExploit == .KFD ?[
            Step(
         title: "Add Customisations",
         description:
           "Add the customisations you want, where you add the modules you want to edit, such as adding Connectivity to edit it's size, or icons, or if you wanted to make some other module become an app launcher.",
         view:step_addcustoms_view
       ),step_editcolors,

        Step(
          title: "Apply Cowabunga Lite",
          description:
            "Due to limits of the KFD exploit, you will need to use Cowabunga Lite once. Follow the tutorial below and apply the \"ControlConfig Reset\" CC preset. Note: This persists on reboot, and you will only have to re-apply this if you re-order in settings **without** ControlConfig applied (read more below).",
          view: AnyView(
            PlayerView().aspectRatio(11 / 8, contentMode: .fit).cornerRadius(8).frame(maxWidth: 500)

          )),
step_applytweaks,

        Step(title: "Reorder modules", description: "To move your modules around (without any gaps), you'll need to do so in iOS settings after having applied Cowabunga Lite **and** ControlConfig. (You can \"apply\" ControlConfig **without any customisations**). If you don't see the fixed modules (e.g Connectivity) after going to settings, come back, apply again, and go back. ⚠️ Warning: If you move your modules while ControlConfig isn't applied, **your setup will break** and you'll have to go back and re-apply Cowabunga Lite.", view: AnyView(
            HStack {
            Button(action: {Haptic.shared.play(.light)}, label:{Label("Apply and open reorder menu", systemImage:"link")})
                Spacer()
            }.padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)).background(
              Material.thick
            ).cornerRadius(10).font(.system(size: 15)))),
        step_finished
        
        ]: [
            Step(
         title: "Add Modules",
         description:
           "Add the modules you want, where you add the modules you want in your control center. **The list of modules you see in the app is all the modules you will see in the control center**, and you can rearrange them in app to move them around. On a module you can edit it's properties, such as adding Connectivity to edit it's size, or icons, or if you wanted to make some other module become an app launcher.",
         view:step_addcustoms_view
       ), step_editcolors, step_applytweaks, step_finished])
      .navigationTitle(
        activeExploit == .MDC ? "Tutorial - MDC" : "Tutorial - KFD"
      )
      .toolbar {
        ToolbarItem {
          Button(
            action: { dismiss() },
            label: {
              Label("Close", systemImage: "xmark")
            })
        }
      }.navigationBarTitleDisplayMode(.inline)

    }
  }
}

// TODO: Previews?
struct TutorialSheetView_Previews: PreviewProvider {
  static var previews: some View {
    TutorialSheetView()
  }
}

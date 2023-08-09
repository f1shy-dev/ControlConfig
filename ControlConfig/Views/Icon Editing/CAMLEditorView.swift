//
//  CAMLEditorView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 16/07/2023.
//

import SwiftUI
struct CALayerRenderer: UIViewRepresentable {
    var layer: CALayer {
        didSet {
            print("layer updated?")
        }
    }
//    var local_layer: CALayer {
//        CALayer(layer: layer)
//    }
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> UIView {
        let svgView = UIView()
        svgView.contentMode = .scaleAspectFit
        //        if let local_layer = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: layer)) as? CALayer{
        layer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        layer.contentsScale = UIScreen.main.scale
        //        layer.backgroundColor = colorScheme == .dark ? UIColor.secondarySystemFill.cgColor : UIColor.black.cgColor
        //        layer.cornerRadius = 10
        layer.isFlipped = true
        layer.setNeedsDisplay()
            svgView.layer.addSublayer(layer)
        
        return svgView
       }

       func updateUIView(_ view: UIView, context: Context) {
//           view.draw(view.bounds)
//           view.setNeedsDisplay()
       }

}


enum EditorState {
    case Loading
    case Editing
    case Error(msg: String)
}

struct CustomSlider<Value: BinaryFloatingPoint >: View where Value.Stride: BinaryFloatingPoint {
    let text: String
    @Binding var value: Value
    @State var wrappedValue: Value {
        didSet {
            value = wrappedValue
        }
    }

    let range: ClosedRange<Value>
    let step: Value.Stride

    init(text: String, value: Binding<Value>, range: ClosedRange<Value>, step: Value.Stride) {
        self.text = text
        self._value = value
        self._wrappedValue = State(wrappedValue: value.wrappedValue)
        self.range = range
        self.step = step
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(text)
                Text(String(format: "%.4f",Double(wrappedValue))).font(.caption2).foregroundColor(.gray)
            }
                Spacer()
                Slider(value: $wrappedValue, in: range, step: step)
                    .frame(width: 125)
                    .onChange(of: wrappedValue) { newValue in
                        value = newValue
                    }
        }.onAppear {
            wrappedValue = value
        }
    }
}


struct LayerEditor:View {
    @State var layer: CALayer
//    @State var rootLayer: CALayer?
    @State private var ctrl: CAStateController?
    @Environment(\.dismiss) private var dismiss
    var isRootLayer: Bool
    var addLayerBackToRoot: ((_ layer: CALayer) -> Void)?
    
    var body: some View {
        List{
            HStack{
                Spacer()
                CALayerRenderer(layer: layer)
                    .frame(width: 48, height: 48)
                    .background(Color.secondary.frame(width: 64,height: 64).cornerRadius(10))
                Spacer()
            }.listRowBackground(Color.clear).listRowInsets(.none).onAppear {
                    ctrl = CAStateController(layer: layer)
                    ctrl?.setInitialStatesOfLayer(layer)
            }
            
            if let sublayers = layer.sublayers{
                Section(header: Text("Sublayers")) {
                    
                    ForEach(sublayers, id: \.description) { sub in
                        NavigationLink {
                            if let idx = layer.sublayers?.firstIndex(of: sub) {
                                LayerEditor(layer: sub, isRootLayer: false) { newsub in

                                    layer.insertSublayer(newsub, at: UInt32(idx))
                                }
                            }
                        } label: {
                            VStack(alignment: .leading){
                                Text(sub.name ?? sub.description)
                                Text("\(String(describing: type(of: sub))) - \((sub.sublayers ?? []).count) sublayers")
                                .font(.caption2).foregroundColor(.gray)
                            }
                        }
                    }.foregroundColor(.accentColor)
                }
            }
            if let states = layer.states as? [CAState]{
                Section(header: Text("State Toggles"), footer: Text("Tap to switch state (with transition, if any).")) {
                    Button("Initial") {
                        ctrl?.setInitialStatesOfLayer(layer, transitionSpeed: 1)
                    }.foregroundColor(.accentColor)
                    ForEach(states, id: \.name) { state in
                        Button(state.name) {
                            ctrl?.setState(state, ofLayer: layer, transitionSpeed: 1)
                        }
                    }.foregroundColor(.accentColor)
                }
            }
            
            if let trans = layer.stateTransitions as? [CAStateTransition]{
                Section(header: Text("State Transitions")) {
                    ForEach(trans,id: \.description) { tran in
                        Button("\(tran.fromState) -> \(tran.toState)") {
                            print((tran.elements as? [CAStateTransitionElement]))
                        }
                    }.foregroundColor(.accentColor)
                }
            }
            
            if let trlayer = layer as? CALayer {
                Section(header: Text("Properties - \(String(describing: type(of: layer)))")) {
                    CustomSlider(text: "Opacity", value: $layer.opacity, range: 0.0...1.0, step: 0.1)

                    Toggle("Hidden", isOn: $layer.isHidden)
                    Toggle("Masks to Bounds", isOn: $layer.masksToBounds)
                    Toggle("Double Sided", isOn: $layer.isDoubleSided)
                    
                    CustomSlider(text: "Corner Radius", value: $layer.cornerRadius, range: 0.0...50.0, step: 1.0)
                    CustomSlider(text: "Border Width", value: $layer.borderWidth, range: 0.0...10.0, step: 1.0)
                    CustomSlider(text: "Shadow Opacity", value: $layer.shadowOpacity, range: 0.0...1.0, step: 0.1)
                    CustomSlider(text: "Shadow Radius", value: $layer.shadowRadius, range: 0.0...50.0, step: 1.0)
                }
            }
        }   .listStyle(SidebarListStyle()).navigationBarBackButtonHidden(true).navigationBarItems(leading:  Button {
            if isRootLayer == false, let addBack = addLayerBackToRoot {
                addBack(layer)
            }
            dismiss()
        } label: {
     Label("Back", systemImage: "arrow.left.circle")
        })        .navigationBarTitle(Text("CAML Editor - ReplayKit"), displayMode: .inline)

            }
}


struct CAMLEditorView: View {
    let caFolderPath: String
    @State private var layer: CALayer?
    
    @State private var editorState: EditorState = .Loading
    
    var body: some View {
        VStack{
        switch editorState {
        case .Loading:
            Text("Loading CAML editor...")
        case .Editing:
            if let layer = layer {
                LayerEditor(layer: layer,isRootLayer: true)
            }
        case .Error(let msg):
            Text("There was an error loading the CAML editor: \(msg)")
        }
    }
            .onAppear {
            do {
                let pack = try CAPackage(contentsOf: URL(fileURLWithPath: caFolderPath), type: kCAPackageTypeCAMLBundle, options: nil)
                layer = pack.rootLayer
                editorState = .Editing
            }
            catch {
                editorState = .Error(msg: "\(error)")
                print(error)
            }
        }
    }
}

//struct CAMLEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        CAMLEditorView()
//    }
//}

//
//  AppCell.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import MarqueeText
import SwiftUI

struct AppCell: View {
    var imagePath: String
    var bundleid: String
    var name: String

    var body: some View {
        HStack(alignment: .center) {
            Group {
                if imagePath.contains("this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao") {
                    Image("Placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    let image = UIImage(contentsOfFile: imagePath)
                    Image(uiImage: image ?? UIImage(named: "Placeholder")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .cornerRadius(6)
            .frame(width: 30, height: 30)

            VStack {
                HStack {
                    MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: .subheadline), leftFade: 16, rightFade: 16, startDelay: 0.5)
                        .padding(.horizontal, 6)
                    Spacer()
                }
//                HStack {
//                    MarqueeText(text: bundleid, font: UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 0.5)
//                        .padding(.horizontal, 6)
//                    Spacer()
//                }
            }
        }
    }
}

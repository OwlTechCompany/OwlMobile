//
//  Loader.swift
//  Owl
//
//  Created by Anastasia Holovash on 13.04.2022.
//

import SwiftUI

let darkBlack = Color(red: 17/255, green: 18/255, blue: 19/255)
let darkGray = Color(red: 41/255, green: 42/255, blue: 48/255)
let darkBlue = Color(red: 96/255, green: 174/255, blue: 201/255)
let darkPink = Color(red: 244/255, green: 132/255, blue: 177/255)
let darkViolet = Color(red: 214/255, green: 189/255, blue: 251/255)
let darkGreen = Color(red: 137/255, green: 192/255, blue: 180/255)

let clearWhite = Color(red: 17/255, green: 18/255, blue: 19/255)
let clearGray = Color(red: 181/255, green: 182/255, blue: 183/255)
let clearBlue = Color(red: 116/255, green: 166/255, blue: 240/255)

struct Loader: View {

    let rotationTime: Double = 0.75
    let animationTime: Double = 1.9 // Sum of all animation times
    let fullRotation: Angle = .degrees(360)
    static let initialDegree: Angle = .degrees(270)

    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.03
    @State var spinnerEndS2S3: CGFloat = 0.03

    @State var rotationDegreeS1 = initialDegree
    @State var rotationDegreeS2 = initialDegree
    @State var rotationDegreeS3 = initialDegree

    var body: some View {
        ZStack {
            Color.white.opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            ZStack {
                // S3
                LoaderCircle(
                    start: spinnerStart,
                    end: spinnerEndS2S3,
                    rotation: rotationDegreeS3,
                    color: darkViolet
                )

                // S2
                LoaderCircle(
                    start: spinnerStart,
                    end: spinnerEndS2S3,
                    rotation: rotationDegreeS2,
                    color: darkPink
                )

                // S1
                LoaderCircle(
                    start: spinnerStart,
                    end: spinnerEndS1,
                    rotation: rotationDegreeS1,
                    color: darkBlue
                )

            }
            .frame(width: Constants.size, height: Constants.size)
        }
        .onAppear {
            animateSpinner()
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { mainTimer in
                self.animateSpinner()
            }
        }
    }

    // MARK: Animation methods
    func animateSpinner(
        with duration: Double,
        completion: @escaping (() -> Void)
    ) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.rotationTime)) {
                completion()
            }
        }
    }

    func animateSpinner() {
        animateSpinner(with: rotationTime) { self.spinnerEndS1 = 1.0 }

        animateSpinner(with: (rotationTime * 2) - 0.025) {
            self.rotationDegreeS1 += fullRotation
            self.spinnerEndS2S3 = 0.8
        }

        animateSpinner(with: (rotationTime * 2)) {
            self.spinnerEndS1 = 0.03
            self.spinnerEndS2S3 = 0.03
        }

        animateSpinner(with: (rotationTime * 2) + 0.0525) { self.rotationDegreeS2 += fullRotation
        }

        animateSpinner(with: (rotationTime * 2) + 0.225) { self.rotationDegreeS3 += fullRotation
        }
    }

}

// MARK: - LoaderCircle

struct LoaderCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: Constants.lineWidth, lineCap: .round))
            .fill(color)
            .rotationEffect(rotation)
    }
}

private enum Constants {
    static let size: CGFloat = 80
    static let lineWidth: CGFloat = 10
}

struct Loader_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Loader()
        }
    }
}

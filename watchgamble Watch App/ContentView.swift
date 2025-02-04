//
//  ContentView.swift
//  Gambling
//
//  Created by Dawson Delap on 1/28/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("moneywatch", store: UserDefaults(suiteName: "group.Dawson.gamble"))
    private var moneywatchSaved: Int = 0
    @State private var rotationAngle = 0.0
    @State private var currentColor: Color = .red
    private let colors: [Color] = [.red, .blue, .green, .purple, .orange]
    private func startColorAnimation() {
            var index = 0
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 2)) {
                    index = (index + 1) % colors.count
                    currentColor = colors[index]
                }
            }
        }
    var body: some View {
        NavigationStack{
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    Text("Gambling")
                        .font(Font.system(size: 20))
                        .foregroundColor(Color.white)
                        .frame(width: 140, height: 35)
                        .background(currentColor)
                        .cornerRadius(10)
                        .onAppear {
                            startColorAnimation()
                            print(UserDefaults(suiteName: "group.Dawson.gamble")?.integer(forKey: "moneywatch") ?? "No value found")
                        }
                    Spacer()
                    VStack {
                        Text("$\(moneywatchSaved)")
                    }.font(Font.system(size: 15))
                        .foregroundColor(Color.white)
                        .frame(width: 100, height: 20)
                        .background(Color(white: 0.24))
                        .cornerRadius(10)
                    NavigationLink(destination: slotsView(
                        money: $moneywatchSaved
                    )) {
                        HStack{
                            Text("Slots").font(Font.system(size: 15))
                                .foregroundColor(Color.white)
                            Image("slots pic")
                                .resizable() // Makes the image resizable
                                .scaledToFit() // Ensures it fits properly
                                .frame(width: 25, height: 25)
                        }
                            .frame(width: 100, height: 35)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }.buttonStyle(PlainButtonStyle())
                    NavigationLink(destination: WheelView(
                        money: $moneywatchSaved
                    )) {
                        HStack{
                            Text("Wheel")
                                .font(Font.system(size: 15))
                                .foregroundColor(Color.white)
                            Image("wheel")
                                .resizable() // Makes the image resizable
                                .scaledToFit() // Ensures it fits properly
                                .frame(width: 25, height: 25)
                                .rotationEffect(.degrees(rotationAngle))
                                .onAppear {
                                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                        rotationAngle = 360
                                    }
                                }
                        }.frame(width: 100, height: 35)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }.buttonStyle(PlainButtonStyle())
                    NavigationLink(destination: doubleView(
                        money: $moneywatchSaved
                    )) {
                        HStack{
                            Text("Double")
                                .font(Font.system(size: 15))
                                .foregroundColor(Color.white)
                                
                            Image("doublepic")
                                .resizable() // Makes the image resizable
                                .scaledToFit() // Ensures it fits properly
                                .frame(width: 25, height: 25)
                        }.frame(width: 100, height: 35)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                }.padding()
            }
        }
    }
}
//MARK:  Slots
//
//  Created by Dawson Delap on 1/14/25.
//
//MARK: Transition func
extension AnyTransition {
    static func moveAndOffset(offsetY: CGFloat) -> AnyTransition {
        AnyTransition.modifier(
            active: OffsetModifier(offsetY: offsetY),
            identity: OffsetModifier(offsetY: 0)
        )
    }

    struct OffsetModifier: ViewModifier {
        let offsetY: CGFloat

        func body(content: Content) -> some View {
            content
                .offset(y: offsetY) // Apply vertical offset only
                .opacity(offsetY == 0 ? 1 : 0)
        }
    }
    static func WheelmoveAndOffset(offsetY: CGFloat) -> AnyTransition {
        AnyTransition.modifier(
            active: OffsetModifier(offsetY: offsetY),
            identity: OffsetModifier(offsetY: 0)
        )
    }

    struct WheelOffsetModifier: ViewModifier {
        let offsetY: CGFloat

        func body(content: Content) -> some View {
            content
                .offset(y: offsetY)
                .opacity(offsetY == 0 ? 0 : 1) // Reverse: Start at 0, fade out when moving
        }
    }
}
struct slotsView: View {
    //MARK: Content View Var
    @State var isBlinking = false
    @State var slot1img: Int = 0
    @State var slot2img: Int = 0
    @State var slot3img: Int = 0
    @State var isDisabled: Bool = false
    @State var autoSpin: Bool = false
    @State var moncolor: Color = .white
    @Binding var money: Int
    @State private var currentTimestamp: String = ""
    @AppStorage("allgains") private var allgainsSaved = ""
    @State public var allgains: String = "" {
        didSet {
            allgainsSaved = allgains
        }
    }
   
    @AppStorage("spinCount") private var spinCountSaved = 0
    @State public var spinCount = 0 {
        didSet {
            spinCountSaved = spinCount
        }
    }
    @State var bet: Double = 5.0
    var images = ["x.circle.fill","globe.americas.fill", "sun.horizon.fill", "7.circle.fill", "car.fill", "heart.circle.fill", "cloud.bolt.rain.fill"]
    var colors = [Color.red, Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink]
    func checkWin() {
        if slot1img == 3 && slot2img == 3 && slot3img == 3 {
            money += 1000000
            updateTimestamp(earned: "$1,000,000")
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isBlinking = true
            }
        }else if slot1img == slot2img && slot2img == slot3img {
            money += 100000
            updateTimestamp(earned: "$100,000")
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isBlinking = true
            }
        }
    }
    
    func updateTimestamp(earned: String) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        currentTimestamp = formatter.string(from: now)
        allgains = "\(currentTimestamp) Spin \(spinCount): +\(earned)\n\n" + allgains
    }
    
    @State var done1 = false
    @State var done2 = false
    func redmoney(){
        if money < 0{
            moncolor = .red
        }else{
            moncolor = .green
        }
    }
    func spin() {
        spinCount += 1
        done1 = false
        done2 = false
        money -= 100
        redmoney()
        let count = 0
        let randomInt1 = Int.random(in: 10...15)
        spinStep1(count: count, randomInt: randomInt1)
        
    }
    func spin2() {
        let count = 0
        let randomInt2 = Int.random(in: 7...12)
        let randomInt3 = Int.random(in: 7...12)
        if done1{
            spinStep2(count: count, randomInt: randomInt2)
            done1 = false
        }
        if done2{
            spinStep3(count: count, randomInt: randomInt3)
            done2 = false
        }
    }

    func spinStep1(count: Int, randomInt: Int) {
        if count <= randomInt {
            withAnimation {
                slot1img = Int.random(in: 1...5)
            }
            let newCount = count + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                spinStep1(count: newCount, randomInt: randomInt)
            }
        }else{
            done1 = true
            spin2()
        }
    }
    func spinStep2(count: Int, randomInt: Int) {
        if count <= randomInt {
            withAnimation {
                slot2img = Int.random(in: 1...5)
            }
            let newCount = count + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                spinStep2(count: newCount, randomInt: randomInt)
            }
        }else{
            done2 = true
            spin2()
        }
    }
    func spinStep3(count: Int, randomInt: Int) {
        if count <= randomInt {
            withAnimation {
                slot3img = Int.random(in: 1...5)
            }
            let newCount = count + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                spinStep3(count: newCount, randomInt: randomInt)
            }
        }else {
            checkWin()
            redmoney()
            if autoSpin{
                spin()
            }else{
                isDisabled = false
            }
        }
    }
    //MARK: Main body
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    HStack{
                        VStack{
                            Text("Money:")
                                .foregroundColor(Color.white)
                            Text("$\(money)")
                                .foregroundColor(moncolor)
                        }.font(Font.system(size: 10))
                            .frame(width: 60, height: 30)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                        VStack{
                            Text("Spins:")
                                .foregroundStyle(Color.white)
                            Text("\(spinCount)")
                                .foregroundColor(Color.white)
                        }.font(Font.system(size: 10))
                            .frame(width: 60, height: 30)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                        
                    }
                    Spacer()
                    HStack{
                        ZStack {
                            Image(systemName: images[slot1img])
                                .font(Font.system(size: 35))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 90)
                                .id(slot1img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50)) // Apply transition
                        }.background(colors[slot1img])
                        .cornerRadius(10)
                        ZStack{
                            Image(systemName: images[slot2img])
                                .font(Font.system(size: 35))
                                .foregroundColor(Color.white)
                                .frame(width: 50, height: 90)
                                .id(slot2img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50))
                        }.background(colors[slot2img])
                            .cornerRadius(10)
                        ZStack{
                            Image(systemName: images[slot3img])
                                .font(Font.system(size: 35))
                                .foregroundColor(Color.white)
                                .frame(width: 50, height: 90)
                                .id(slot3img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50))
                        }.background(colors[slot3img])
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    VStack{
                        HStack{
                            VStack{ // Adjust spacing here
                                Toggle("", isOn: $autoSpin)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                Text("Auto")
                                    .font(Font.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50, height: 40)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                            Button(action: {
                                withAnimation{
                                    spin()
                                    isDisabled = true
                                }
                            }) {
                                Label("Spin", systemImage: "arrow.triangle.2.circlepath")
                                    .font(Font.system(size: 15))
                                    .foregroundColor(Color.white)
                                    .frame(width: 60, height: 40)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }.disabled(isDisabled)
                                .buttonStyle(PlainButtonStyle())
                            NavigationLink(destination: gainsView(
                                allgains: $allgains,
                                isBlinking: $isBlinking
                            )) {
                                Text("Gains")
                                    .font(Font.system(size: 10))
                                    .foregroundColor(Color.white)
                                    .frame(width: 50, height: 40)
                                    .background(isBlinking ? Color(white: 0.5) : Color(white: 0.3))
                                    .cornerRadius(10)
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                    //MARK: On Appear
                }.onAppear() {
                    //money = 0
                    //allgains = ""
                    //spinCount = 0
                    allgains = allgainsSaved
                    spinCount = spinCountSaved
                    redmoney()
                }
                .padding()
            }
        }
    }
}
//MARK: GainsView
struct gainsView: View {
    @Binding var allgains: String
    @Binding var isBlinking: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack {
                if allgains == "" {
                    Spacer()
                    Text("No gains yet")
                        .foregroundStyle(Color.white)
                        .font(Font.system(size: 30))
                    Spacer()
                }else{
                    ScrollView{
                        Text("\(allgains)")
                            .foregroundStyle(Color.white)
                            .font(Font.system(size: 15))
                            .padding(.horizontal, 30)
                    }
                }
            }.onAppear(){
                withAnimation(){
                    isBlinking = false
                }
            }
        }
    }
}
//MARK: Wheel View
struct WheelView: View {
    @State private var angle: Double = 0
    @State private var angle360 = 0
    @State private var gained = ""
    @State private var landed = ""
    @State var gaincolor: Color = .white
    @Binding var money: Int
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack {
                Text("$\(money)").font(Font.system(size: 15))
                    .foregroundColor(Color.white)
                    .frame(width: 120, height: 30)
                    .background(Color(white: 0.3))
                    .cornerRadius(10)
                    .id(money)
                Image("wheel")
                    .resizable() // Makes the image resizable
                    .scaledToFit() // Ensures it fits properly
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(angle))
                    .animation(.easeInOut(duration: 2), value: angle)
                    .onTapGesture {withAnimation {
                        
                        angle += Double.random(in: 720...1024)// Rotates 45 degrees each tap
                            angle360 = Int(floor(angle)) % 360
                            if angle360 > 1 && angle360 < 45 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "+10000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "lightgreen"
                                        money += 10000
                                    }
                                }
                            }else if angle360 > 46 && angle360 <= 90 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "+20000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "green"
                                        money += 20000
                                    }
                                }
                            }else if angle360 > 91 && angle360 <= 135 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "+30000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "yellow"
                                        money += 30000
                                    }
                                }
                            }else if angle360 > 135 && angle360 <= 180 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "back to 0"
                                    gaincolor = .red
                                    withAnimation{
                                        landed = "red"
                                        money -= money
                                    }
                                }
                            }else if angle360 > 180 && angle360 <= 225 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "-30000"
                                    gaincolor = .red
                                    withAnimation{
                                        landed = "grey"
                                        money -= 30000
                                    }
                                }
                            }else if angle360 > 225 && angle360 <= 270 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "+40000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "pink"
                                        money += 40000
                                    }
                                }
                            }else if angle360 > 270 && angle360 <= 315 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "+30000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "darkblue"
                                        money += 30000
                                    }
                                }
                            }else if angle360 > 315 && angle360 <= 360 || angle360 == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    
                                    gained = "+20000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "blue"
                                        money += 20000
                                    }
                                }
                            }
                        }
                    }
                Image(systemName: "arrow.up")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 25, height: 25)
                    .onDisappear(){
                        
                    }
                
            }
            .padding()
        }
    }
}
import SwiftUI
//MARK: double View
struct doubleView: View {
    @State private var number = 0
    @State private var lose = 0
    @State private var bet = 0
    @State private var intValue: String = ""
    @State var attempts: Int = 0
    @Binding var money: Int
    struct Shake: GeometryEffect {
        var amount: CGFloat = 10
        var shakesPerUnit = 3
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(CGAffineTransform(translationX:
                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
        }
    }
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack {
                Text("$\(money)")
                    .frame(width: 120, height: 30)
                    .background(Color(white: 0.3))
                    .cornerRadius(10)
                    .foregroundStyle(Color.white)
                Spacer()
                Text("\(number)")
                    .font(Font.system(size: 60))
                    .foregroundColor(Color.white)
                    .frame(width: 115, height: 115)
                    .background(Color.red)
                    .cornerRadius(15)
                    .font(.largeTitle)
                    .modifier(Shake(animatableData: CGFloat(attempts)))
                HStack{
                    Button(action: {
                        if number == 0 {
                            number += 2
                            money -= 2
                        }else{
                            lose = Int.random(in: 1...100)
                            if lose > 15 {
                                number *= 2
                            }else{
                                number = 0
                            }
                        }
                        withAnimation(.default) {
                            self.attempts += number/4
                        }
                        
                    }) {
                        Text("Double")
                            .font(Font.system(size: 15))
                            .foregroundColor(Color.white)
                            .frame(width: 60, height: 35)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }.buttonStyle(PlainButtonStyle())
                    Button(action: {
                        money += number
                        number = 0
                        
                    }) {
                        VStack{
                            Text("Cash")
                            Text("Out")
                        }
                            .font(Font.system(size: 15))
                            .foregroundColor(Color.white)
                            .frame(width: 60, height: 35)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }.buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }.padding()
            
        }
    }
}

#Preview {
    ContentView()
}

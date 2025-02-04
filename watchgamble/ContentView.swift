//
//  ContentView.swift
//  Gambling
//
//  Created by Dawson Delap on 1/28/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("money") private var moneySaved = 0
    @State public var money = 0 {
        didSet {
            moneySaved = money
        }
    }
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
                        .font(Font.system(size: 60))
                        .foregroundColor(Color.white)
                        .frame(width: 350, height: 150)
                        .background(currentColor)
                        .cornerRadius(20)
                        .onAppear {
                            startColorAnimation()
                        }
                    Spacer()
                    VStack {
                        Text("Current Money:")
                        Text("$\(moneySaved)")
                    }.font(Font.system(size: 20))
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 80)
                        .background(Color(white: 0.24))
                        .cornerRadius(10)
                    NavigationLink(destination: slotsView(
                        money: $money,
                        moneySaved: $moneySaved
                    )) {
                        HStack{
                            Text("Slots").font(Font.system(size: 40))
                                .foregroundColor(Color.white)
                            Image("slots pic")
                                .resizable() // Makes the image resizable
                                .scaledToFit() // Ensures it fits properly
                                .frame(width: 50, height: 50)
                        }
                            .frame(width: 200, height: 100)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: WheelView(
                        money: $money,
                        moneySaved: $moneySaved
                    )) {
                        HStack{
                            Text("Wheel")
                                .font(Font.system(size: 40))
                                .foregroundColor(Color.white)
                            Image("wheel")
                                .resizable() // Makes the image resizable
                                .scaledToFit() // Ensures it fits properly
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(rotationAngle))
                                .onAppear {
                                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                        rotationAngle = 360
                                    }
                                }
                        }.frame(width: 200, height: 100)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: doubleView(
                        money: $money,
                        moneySaved: $moneySaved
                    )) {
                        HStack{
                            Text("Double")
                                .font(Font.system(size: 35))
                                .foregroundColor(Color.white)
                                
                            Image("doublepic")
                                .resizable() // Makes the image resizable
                                .scaledToFit() // Ensures it fits properly
                                .frame(width: 50, height: 50)
                        }.frame(width: 200, height: 100)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: blackjackView(
                        money: $money,
                        moneySaved: $moneySaved
                    )) {
                        HStack{
                            Text("Jack")
                                .font(Font.system(size: 35))
                                .foregroundColor(Color.white)
                                .padding(.horizontal)
                            Image("jackpic")
                                .resizable() // Makes the image resizable
                                .scaledToFit() // Ensures it fits properly
                                .frame(width: 50, height: 50)
                        }.frame(width: 200, height: 100)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                    }
                    Spacer()
                }.padding()
                    .onAppear {
                        
                    }
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
    @Binding var moneySaved: Int
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
                        }.font(Font.system(size: 20))
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                        VStack{
                            Text("Spins:")
                                .foregroundStyle(Color.white)
                            Text("\(spinCount)")
                                .foregroundColor(Color.white)
                        }.font(Font.system(size: 20))
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                        
                    }
                    Spacer()
                    HStack{
                        ZStack {
                            Image(systemName: images[slot1img])
                                .font(Font.system(size: 50))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 200)
                                .id(slot1img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50)) // Apply transition
                        }.background(colors[slot1img])
                        .cornerRadius(10)
                        ZStack{
                            Image(systemName: images[slot2img])
                                .font(Font.system(size: 50))
                                .foregroundColor(Color.white)
                                .frame(width: 120, height: 200)
                                .id(slot2img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50))
                        }.background(colors[slot2img])
                            .cornerRadius(10)
                        ZStack{
                            Image(systemName: images[slot3img])
                                .font(Font.system(size: 50))
                                .foregroundColor(Color.white)
                                .frame(width: 120, height: 200)
                                .id(slot3img) // Ensures unique identity
                                .transition(.moveAndOffset(offsetY: -50))
                        }.background(colors[slot3img])
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    VStack{
                        HStack{
                            HStack{ // Adjust spacing here
                                Toggle("", isOn: $autoSpin)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                Text("Auto")
                                    .foregroundColor(.white)
                            }
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(10)
                            Button(action: {
                                withAnimation{
                                    spin()
                                    isDisabled = true
                                }
                            }) {
                                Label("Spin", systemImage: "arrow.triangle.2.circlepath")
                                    .font(Font.system(size: 20))
                                    .foregroundColor(Color.white)
                                    .frame(width: 120, height: 60)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }.disabled(isDisabled)
                            NavigationLink(destination: gainsView(
                                allgains: $allgains,
                                isBlinking: $isBlinking
                            )) {
                                Text("Gains")
                                    .font(Font.system(size: 20))
                                    .foregroundColor(Color.white)
                                    .frame(width: 120, height: 60)
                                    .background(isBlinking ? Color(white: 0.5) : Color(white: 0.3))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    //MARK: On Appear
                }.onAppear() {
                    //money = 0
                    //allgains = ""
                    //spinCount = 0
                    money = moneySaved
                    allgains = allgainsSaved
                    spinCount = spinCountSaved
                    redmoney()
                }
                .onDisappear(){
                    moneySaved = money
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
                Text("Gains")
                    .foregroundStyle(Color.white)
                    .font(Font.system(size: 50))
                if allgains == "" {
                    Spacer()
                    Text("No gains yet")
                        .foregroundStyle(Color.white)
                        .font(Font.system(size: 50))
                    Spacer()
                }else{
                    ScrollView{
                        Text("\(allgains)")
                            .foregroundStyle(Color.white)
                            .font(Font.system(size: 25))
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
    @Binding var moneySaved: Int
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack {
                Image("wheel")
                    .resizable() // Makes the image resizable
                    .scaledToFit() // Ensures it fits properly
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(angle))
                    .animation(.easeInOut(duration: 2), value: angle)
                    .onTapGesture {withAnimation {
                        
                        angle += Double.random(in: 720...1024)// Rotates 45 degrees each tap
                            angle360 = Int(floor(angle)) % 360
                            if angle360 > 1 && angle360 < 45 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
                                    gained = "+10000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "lightgreen"
                                        money += 10000
                                    }
                                }
                            }else if angle360 > 46 && angle360 <= 90 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
                                    gained = "+20000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "green"
                                        money += 20000
                                    }
                                }
                            }else if angle360 > 91 && angle360 <= 135 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
                                    gained = "+30000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "yellow"
                                        money += 30000
                                    }
                                }
                            }else if angle360 > 135 && angle360 <= 180 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
                                    gained = "back to 0"
                                    gaincolor = .red
                                    withAnimation{
                                        landed = "red"
                                        money -= money
                                    }
                                }
                            }else if angle360 > 180 && angle360 <= 225 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
                                    gained = "-30000"
                                    gaincolor = .red
                                    withAnimation{
                                        landed = "grey"
                                        money -= 30000
                                    }
                                }
                            }else if angle360 > 225 && angle360 <= 270 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
                                    gained = "+40000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "pink"
                                        money += 40000
                                    }
                                }
                            }else if angle360 > 270 && angle360 <= 315 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
                                    gained = "+30000"
                                    gaincolor = .green
                                    withAnimation{
                                        landed = "darkblue"
                                        money += 30000
                                    }
                                }
                            }else if angle360 > 315 && angle360 <= 360 || angle360 == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                                    moneySaved = money
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
                    .frame(width: 50, height: 50)
                    .onAppear(){
                        money = moneySaved
                    }
                    .onDisappear(){
                        moneySaved = money
                    }
                Text("$\(money)").font(Font.system(size: 20))
                    .foregroundColor(Color.white)
                    .frame(width: 120, height: 60)
                    .background(Color(white: 0.3))
                    .cornerRadius(10)
                    .id(money)
                Text("\(gained)")
                    .foregroundStyle(gaincolor)
                    .id(landed)
                    .transition(.WheelmoveAndOffset(offsetY: 1).combined(with: .opacity))
                    .animation(.easeInOut(duration: 3), value: landed)
            }
            .padding()
        }.onAppear(){
            money = moneySaved
        }
        .onDisappear(){
            moneySaved = money
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
    @Binding var moneySaved: Int
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
                    .frame(width: 120, height: 60)
                    .background(Color(white: 0.3))
                    .cornerRadius(15)
                    .foregroundStyle(Color.white)
                Spacer()
                Text("\(number)")
                    .font(Font.system(size: 80))
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 300)
                    .background(Color.red)
                    .cornerRadius(30)
                    .font(.largeTitle)
                    .modifier(Shake(animatableData: CGFloat(attempts)))
                    .onAppear {
                        money = moneySaved
                    }
                    .onDisappear() {
                        moneySaved = money
                    }
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
                        moneySaved = money
                    }) {
                        Text("Double")
                            .font(Font.system(size: 27))
                            .foregroundColor(Color.white)
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.4))
                            .cornerRadius(15)
                    }
                    Button(action: {
                        money += number
                        number = 0
                        moneySaved = money
                    }) {
                        Text("Cash out")
                            .font(Font.system(size: 27))
                            .foregroundColor(Color.white)
                            .frame(width: 120, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(15)
                    }
                }
                HStack {
                    TextField("Enter your score", value: $bet, format: .number)
                        .padding()
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120, maxHeight: 40)
                        .foregroundColor(.white)
                        .background(Color(white: 0.2))
                        .font(.largeTitle)
                        .cornerRadius(10)
                    Button(action: {
                        number = bet
                        money -= bet
                    }) {
                        Text("Bet")
                            .font(Font.system(size: 27))
                            .foregroundColor(Color.white)
                            .frame(width: 60, height: 40)
                            .background(Color(white: 0.4))
                            .cornerRadius(10)
                    }
                }.frame(width: 240, height: 60)
                    .background(Color(white: 0.3))
                    .cornerRadius(15)
                Spacer()
            }.padding()
            
        }
    }
}

//MARK:  BlackJack
//Created by Dawson Delap on 1/31/25.

import SwiftUI
import Foundation
// MARK: Cards
var cards = [
        "clubs_2", "clubs_3", "clubs_4", "clubs_5", "clubs_6", "clubs_7", "clubs_8", "clubs_9", "clubs_10",
        "clubs_jack", "clubs_queen", "clubs_king", "clubs_ace", // 0-12
        "diamonds_2", "diamonds_3", "diamonds_4", "diamonds_5", "diamonds_6", "diamonds_7", "diamonds_8", "diamonds_9", "diamonds_10",
        "diamonds_jack", "diamonds_queen", "diamonds_king", "diamonds_ace", // 13-25
        "hearts_2", "hearts_3", "hearts_4", "hearts_5", "hearts_6", "hearts_7", "hearts_8", "hearts_9", "hearts_10",
        "hearts_jack", "hearts_queen", "hearts_king", "hearts_ace", // 26-38
        "spades_2", "spades_3", "spades_4", "spades_5", "spades_6", "spades_7", "spades_8", "spades_9", "spades_10",
        "spades_jack",  "spades_queen", "spades_king", "spades_ace" // 39-51
    ]
// MARK: card values
var cardValues: [String: Int] = [
    "clubs_2": 2, "clubs_3": 3, "clubs_4": 4, "clubs_5": 5, "clubs_6": 6, "clubs_7": 7, "clubs_8": 8, "clubs_9": 9, "clubs_10": 10,
    "clubs_jack": 10, "clubs_queen": 10, "clubs_king": 10, "clubs_ace": 11,
    
    "diamonds_2": 2, "diamonds_3": 3, "diamonds_4": 4, "diamonds_5": 5, "diamonds_6": 6, "diamonds_7": 7, "diamonds_8": 8, "diamonds_9": 9, "diamonds_10": 10,
    "diamonds_jack": 10, "diamonds_queen": 10, "diamonds_king": 10, "diamonds_ace": 11,
    
    "hearts_2": 2, "hearts_3": 3, "hearts_4": 4, "hearts_5": 5, "hearts_6": 6, "hearts_7": 7, "hearts_8": 8, "hearts_9": 9, "hearts_10": 10,
    "hearts_jack": 10, "hearts_queen": 10, "hearts_king": 10, "hearts_ace": 11,
    
    "spades_2": 2, "spades_3": 3, "spades_4": 4, "spades_5": 5, "spades_6": 6, "spades_7": 7, "spades_8": 8, "spades_9": 9, "spades_10": 10,
    "spades_jack": 10, "spades_queen": 10, "spades_king": 10, "spades_ace": 11
]
// max 51
struct blackjackView: View {
    @State private var playerCards: [String] = []
    @State private var dealerCards: [String] = []
    @State private var playerscore: Int = 0
    @State private var dealerscore: Int = 0
    @State private var win: String = ""
    @State private var gameover: Bool = false
    @State private var isFlipped: Bool = false
    @State private var flipcard: String = "back"
    @State private var disable: Bool = false
    @Binding var money: Int
    @Binding var moneySaved: Int
    func hitAction() {
        if let newCard = cards.randomElement() {
            playerCards.append(newCard) // Adds a new card to the player's hand
            if let prindex = cards.firstIndex(of: newCard) {
                cards.remove(at: prindex)
            }
        }
    }
    func standAction() {
        if !isFlipped{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let newCard = cards.randomElement() {
                    flipcard = newCard // Adds a new card to the player's hand
                    if let prindex = cards.firstIndex(of: newCard) {
                        cards.remove(at: prindex)
                    }
                    if newCard.contains("ace") && dealerscore + 11 > 22{
                        dealerscore += 1
                    }else{
                        dealerscore += cardValues[newCard] ?? 0
                    }
                }
            }
            
            withAnimation {
                isFlipped.toggle()
            }
        }
        if dealerscore <= playerscore{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation{
                    if let newCard = cards.randomElement() {
                        dealerCards.append(newCard) // Adds a new card to the player's hand
                        if let drindex = cards.firstIndex(of: newCard) {
                            cards.remove(at: drindex)
                        }
                        if newCard.contains("ace") && dealerscore + 11 > 22{
                            dealerscore += 1
                        }else{
                            dealerscore += cardValues[newCard] ?? 0
                        }
                    }
                }
                standAction()
            }
        }else if dealerscore > playerscore{
            standcheck()
        }
    }
    func hitcheck(){
        if dealerscore == 21{
            win = "Dealer Wins -$1000"
            money -= 1000
            gameover = true
        }else if playerscore == 21{
            win = "Player Wins +$1000"
            money += 1000
            gameover = true
        }else if dealerscore > 21{
            win = "Player Wins +$1000"
            money += 1000
            gameover = true
        }else if playerscore > 21{
            win = "Dealer Wins -$1000"
            money -= 1000
            gameover = true
        }
    }
    func standcheck(){
        if dealerscore < 21 && playerscore < 21 && playerscore > dealerscore{
            win = "Player Wins +$1000"
            money += 1000
            gameover = true
        }else if dealerscore < 21 && playerscore < 21 && playerscore < dealerscore{
            win = "Dealer Wins -$1000"
            money -= 1000
            gameover = true
        }else if dealerscore > 21{
            win = "Player Wins +$1000"
            money += 1000
            gameover = true
        }else if playerscore > 21{
            win = "Dealer Wins -$1000"
            money -= 1000
            gameover = true
        }else if dealerscore == 21{
            win = "Dealer Wins -$1000"
            money -= 1000
            gameover = true
        }else if playerscore == 21{
            win = "Player Wins +$1000"
            money += 1000
            gameover = true
        }
    }
    //MARK: Black Jack Body
    var body: some View {
        ZStack{
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0, green: 0.4, blue: 0), Color(red: 0, green: 0.4, blue: 0), ]),
                    startPoint: .top,
                    endPoint: .bottom
                ).onAppear(){
                    withAnimation{
                        if let newCard = cards.randomElement() {
                            playerCards.append(newCard) // Adds a new card to the player's hand
                            if let prindex = cards.firstIndex(of: newCard) {
                                cards.remove(at: prindex)
                            }
                        }
                        if let newCard = cards.randomElement() {
                            playerCards.append(newCard) // Adds a new card to the player's hand
                            if let prindex = cards.firstIndex(of: newCard) {
                                cards.remove(at: prindex)
                            }
                        }
                        if let newCard = cards.randomElement() {
                            dealerCards.append(newCard) // Adds a new card to the player's hand
                            if let drindex = cards.firstIndex(of: newCard) {
                                cards.remove(at: drindex)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack{
                    // dealer card 1
                    ZStack{
                        Image(flipcard)
                           .resizable()
                           .frame(width: 175, height: 250)
                           .offset(x: CGFloat(-1) * 25 - 12.5, y: 0) // Adjusted offset
                           .rotation3DEffect(.degrees(isFlipped ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                           .animation(.easeInOut(duration: 0.6), value: isFlipped)
                        ForEach(Array(dealerCards.enumerated()), id: \.element) { index, card in
                            Image(card)
                                .resizable()
                                .frame(width: 175, height: 250)
                                .offset(x: CGFloat(index) * 25 - CGFloat(dealerCards.count - 1) * 12.5, y: 0)
                                .transition(index == dealerCards.count - 1 ? .move(edge: .trailing) : .identity) // Only new card slides in
                                .animation(.easeInOut(duration: 0.3), value: dealerCards) // Animate card updates
                                .onAppear {
                                    if !isFlipped{
                                        if card.contains("ace") && dealerscore + 11 > 22{
                                            dealerscore += 1
                                        }else{
                                            dealerscore += cardValues[card] ?? 0
                                        }
                                    }
                                }
                        }
                    }
                    Text("Dealer Score: \(dealerscore)")
                        .font(Font.system(size: 27))
                        .offset(x: 0, y: 3)
                    Spacer()
                    
                    ZStack {
                        Text("$\(money)")
                            .font(Font.system(size: 27))
                            .offset(x: 0, y: -200)
                        Text("Your Score: \(playerscore)")
                            .font(Font.system(size: 27))
                            .offset(x: 0, y: -160)
                        
                        ForEach(Array(playerCards.enumerated()), id: \.element) { index, card in
                            Image(card)
                                .resizable()
                                .frame(width: 175, height: 250)
                                .offset(x: CGFloat(index) * 25 - CGFloat(playerCards.count - 1) * 12.5, y: 0) // Shifts older cards back
                                .transition(index == playerCards.count - 1 ? .move(edge: .trailing) : .identity) // Only new card slides in
                                .animation(.easeInOut(duration: 0.3), value: playerCards) // Animate card updates
                                .onAppear {
                                    if card.contains("ace") && playerscore + 11 > 21{
                                        playerscore += 1
                                    }else{
                                        playerscore += cardValues[card] ?? 0
                                    }
                                    hitcheck()
                                }
                        }
                    }
                    HStack{
                        Button(action: {
                            disable = true
                            withAnimation{
                                hitAction()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                disable = false
                            }
                        }) {
                            Text("Hit")
                                .font(Font.system(size: 27))
                                .foregroundColor(Color.white)
                                .frame(width: 175, height: 60)
                                .background(Color(white: 0.3))
                                .cornerRadius(15)
                                
                        }.disabled(disable)
                        Button(action: {
                            disable = true
                            withAnimation{
                                standAction()
                                
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                disable = false
                            }
                        }) {
                            Text("Stand")
                                .font(Font.system(size: 27))
                                .foregroundColor(Color.white)
                                .frame(width: 175, height: 60)
                                .background(Color(white: 0.3))
                                .cornerRadius(15)
                                
                        }.disabled(disable)
                    }
                }
                if gameover {
                    Color.black
                        .opacity(0.4) // Adjust opacity to control the darkness
                        .blur(radius: 10) // Blur effect
                        .edgesIgnoringSafeArea(.all)
                    
                    // Centered Text
                    Text(win)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(1.0)
                        .offset(y: -75)
                    Button(action: {
                        playerCards = []
                        dealerCards = []
                        playerscore = 0
                        dealerscore = 0
                        win = ""
                        gameover = false
                        isFlipped = false
                        flipcard = "back"
                        cards = [
                                "clubs_2", "clubs_3", "clubs_4", "clubs_5", "clubs_6", "clubs_7", "clubs_8", "clubs_9", "clubs_10",
                                "clubs_jack", "clubs_queen", "clubs_king", "clubs_ace", // 0-12
                                "diamonds_2", "diamonds_3", "diamonds_4", "diamonds_5", "diamonds_6", "diamonds_7", "diamonds_8", "diamonds_9", "diamonds_10",
                                "diamonds_jack", "diamonds_queen", "diamonds_king", "diamonds_ace", // 13-25
                                "hearts_2", "hearts_3", "hearts_4", "hearts_5", "hearts_6", "hearts_7", "hearts_8", "hearts_9", "hearts_10",
                                "hearts_jack", "hearts_queen", "hearts_king", "hearts_ace", // 26-38
                                "spades_2", "spades_3", "spades_4", "spades_5", "spades_6", "spades_7", "spades_8", "spades_9", "spades_10",
                                "spades_jack",  "spades_queen", "spades_king", "spades_ace" // 39-51
                            ]
                        if let newCard = cards.randomElement() {
                            playerCards.append(newCard) // Adds a new card to the player's hand
                            if let prindex = cards.firstIndex(of: newCard) {
                                cards.remove(at: prindex)
                            }
                        }
                        if let newCard = cards.randomElement() {
                            playerCards.append(newCard) // Adds a new card to the player's hand
                            if let prindex = cards.firstIndex(of: newCard) {
                                cards.remove(at: prindex)
                            }
                        }
                        if let newCard = cards.randomElement() {
                            dealerCards.append(newCard) // Adds a new card to the player's hand
                            if let drindex = cards.firstIndex(of: newCard) {
                                cards.remove(at: drindex)
                            }
                        }
                    }) {
                        Text("Reset")
                            .font(Font.system(size: 27))
                            .foregroundColor(Color.white)
                            .frame(width: 175, height: 60)
                            .background(Color(white: 0.3))
                            .cornerRadius(15)
                            .opacity(50)
                            .offset(y: -25)
                    }
                }
            }
        }.onAppear {
            moneySaved = money
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}

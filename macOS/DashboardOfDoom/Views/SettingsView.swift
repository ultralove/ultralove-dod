import SwiftUI

struct SettingsView: View {
    @Environment(ColorPresenter.self) private var colorScheme
    @AppStorage("enableDarkTheme") private var enableDarkTheme: Bool = false
    @AppStorage("selectedColor") private var selectedColorString: String = ""

    @State private var selectedColor: Color? = .cyan
    let colors: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .teal,
        .cyan,
        .blue,
        .indigo,
        .purple,
        .pink,
        .brown,
        .white,
        .gray,
        .black
    ]
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)

    @AppStorage("showFederalElectionPolls") private var showFederalElectionPolls: Bool = false

    @Environment(LevelPresenter.self) private var level
    @AppStorage("nearestLevelSensor") private var nearestLevelSensor: Bool = false

    @Environment(ParticlePresenter.self) private var particles
    @AppStorage("nearestParticleSensor") private var nearestParticleSensor: Bool = false

    @Environment(SurveyPresenter.self) private var electionPolls
    @AppStorage("enableElectionPolls") private var enableElectionPolls: Bool = false
    @AppStorage("electionPollScope") private var electionPollScope: Int = 1

    var body: some View {
        Form {
            Section(header: Text("General")) {
                VStack {
                    Toggle("Always Use Dark Theme", isOn: $enableDarkTheme)
                    HStack {
                        Text("Always use the dark color theme. This setting overrides the system theme.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                VStack {
                    HStack {
                        Text("Accent Color")
                        Spacer()
                    }
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(colors, id: \.self) { color in
                            Rectangle()
                                .fill(color)
                                .frame(width: 33, height: 33)
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                    colorScheme.tintColor = color
                                }
                        }
                    }
                    .padding()
                    HStack {
                        Text("Color that should be used for the accent color.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            Section(header: Text("Home")) {
                VStack {
                    Toggle("Show Federal Election Polls", isOn: $showFederalElectionPolls)
                        .onChange(of: showFederalElectionPolls) { _, _ in
                            ProcessManager.shared.refreshSubscription(subscriber: electionPolls)
                        }
                    HStack {
                        Text("Show federal elections on the map view.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .disabled((enableElectionPolls == false) || (electionPollScope == 1))
            }
            Section(header: Text("Water")) {
                VStack {
                    Toggle("Nearest Sensor", isOn: $nearestLevelSensor)
                        .onChange(of: nearestLevelSensor) { _, _ in
                            ProcessManager.shared.refreshSubscription(subscriber: level)
                        }
                    HStack {
                        Text(
                            "Always select the nearest sensor, even if it is located at an artificial water body."
                        )
                        .font(.footnote)
                        .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            Section(header: Text("Particulate Matter")) {
                VStack {
                    Toggle("Nearest Sensor", isOn: $nearestParticleSensor)
                        .onChange(of: nearestParticleSensor) { _, _ in
                            ProcessManager.shared.refreshSubscription(subscriber: particles)
                        }
                    HStack {
                        Text(
                            "Always select the nearest sensor, even if it doesn't provide \u{1D40F}\u{1D40C}\u{2081}\u{2080}, \u{1D40F}\u{1D40C}\u{2082}\u{2085}, \u{1D40E}\u{2083} and \u{1D40D}\u{1D40E}\u{2082}."
                        )
                        .font(.footnote)
                        .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            Section(header: Text("Election Polls")) {
                VStack {
                    Toggle("Enable", isOn: $enableElectionPolls)
                        .onChange(of: enableElectionPolls) { oldValue, newValue in
                            ProcessManager.shared.resetSubscription(subscriber: electionPolls)
                            if (oldValue == false) && (newValue == true) {
                                ProcessManager.shared.refreshSubscription(subscriber: electionPolls)
                            }
                        }
                }
                VStack {
                    Picker("Scope", selection: $electionPollScope) {
                        Text("Federal").tag(0)
                        Text("State").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: electionPollScope) { _, _ in
                        ProcessManager.shared.resetSubscription(subscriber: electionPolls)
                        ProcessManager.shared.refreshSubscription(subscriber: electionPolls)
                    }
                    HStack {
                        Text("Show federal or state parliament election polls.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .disabled(enableElectionPolls == false)
            }
        }
    }
}

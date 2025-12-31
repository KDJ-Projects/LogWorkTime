//
//  ContentView.swift
//  LogWorkTime
//
//  Created by Kurt De Jonghe on 30/12/2025.
//

internal import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkHourViewModel()
    @State private var editingWorkHour: WorkHour? = nil
    @State private var newEndTime: Date = Date()
    
    @State private var startDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    
    @State private var breakTime: Double = 0.50

    var body: some View {
        NavigationView {
            VStack {
                Text("Totaal uren: \(viewModel.totalHours, specifier: "%.2f")uur")
                    .foregroundStyle(.secondary)
                    .bold()
                HStack {
                    VStack {
                        DatePicker("Datum", selection: $startDate, displayedComponents: .date)
                        
                        DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)

                        DatePicker("Einde", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }
                .padding(.horizontal, 20)
                
                Button("Voeg toe") {
                    let calendar = Calendar.current

                    // Extract date components (Y/M/D) from the selected startDate
                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)

                    // Extract hour/minute from the selected start and end times
                    let startHour = calendar.component(.hour, from: startTime)
                    let startMinute = calendar.component(.minute, from: startTime)
                    let endHour = calendar.component(.hour, from: endTime)
                    let endMinute = calendar.component(.minute, from: endTime)

                    // Build combined start and end Date values
                    let workDate = Calendar.current.date(from: dateComponents) ?? startDate
                    
                    var startComponents = dateComponents
                    startComponents.hour = startHour
                    startComponents.minute = startMinute

                    var endComponents = dateComponents
                    endComponents.hour = endHour
                    endComponents.minute = endMinute

                    if let startCombined = calendar.date(from: startComponents),
                       let endCombined = calendar.date(from: endComponents) {
                        if endCombined > startCombined {
                            viewModel
                                .addWorkHour(
                                    date: workDate,
                                    start: startCombined,
                                    end: endCombined
                                )
                            viewModel.saveWorkHours()
                            // Reset the inputs to now for convenience
                            startDate = Date()
                            startTime = Date()
                            endTime = Date()
                        } else {
                            print("Eindtijd moet na starttijd zijn.")
                        }
                    } else {
                        print("Kon geen geldige datums samenstellen uit de invoer.")
                    }
                }
                .buttonStyle(GlassProminentButtonStyle())
                .padding(.bottom)
                
                List {
                    ForEach(viewModel.workHours.sorted(by: { $0.startDate < $1.startDate})) { workHour in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(workHour.startDate, formatter: viewModel.dateOnlyFormatter)")
                                Spacer()
                                Text("Gewerkt: \(workHour.hours - breakTime, specifier: "%.2f") uur")
                            }
                            .foregroundStyle(.blue)
                            
                            HStack {
                                Text("Startwerk: \(workHour.startTime, formatter: viewModel.itemFormatter)")
                                Spacer()
                                Text("Eindewerk: \(workHour.endTime, formatter: viewModel.itemFormatter)")
                            }
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            
                        }
                        .swipeActions {
                            Button("Bewerk") {
                                editingWorkHour = workHour
                                newEndTime = workHour.endTime
                            }
                            .tint(.blue)
                            
                            Button(role: .destructive) {
                                if let index = viewModel.workHours.firstIndex(where: { $0.id == workHour.id}) {
                                    viewModel.workHours.remove(at: index)
                                    viewModel.saveWorkHours()
                                }
                            } label: {
                                Text("Verwijder")
                            }
                        }
                    }
                }
            }
            .sheet(item: $editingWorkHour) { workHour in
                NavigationView {
                    VStack(spacing: 16) {
                        Text("Bewerk eindtijd")
                            .font(.headline)
                        DatePicker("Einde", selection: $newEndTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        Spacer()
                    }
                    .padding()
                    .navigationTitle(Text("Bewerk Uren"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuleer") {
                                editingWorkHour = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Bewaar") {
                                if let index = viewModel.workHours.firstIndex(where: { $0.id == workHour.id }) {
                                    // Ensure new end time is after start time; if not, adjust date component to same day as start.
                                    let calendar = Calendar.current
                                    let start = viewModel.workHours[index].startTime
                                    var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: newEndTime)
                                    let startComps = calendar.dateComponents([.year, .month, .day], from: start)
                                    comps.year = startComps.year
                                    comps.month = startComps.month
                                    comps.day = startComps.day
                                    let adjustedEnd = calendar.date(from: comps) ?? newEndTime
                                    if adjustedEnd > start {
                                        viewModel.workHours[index].endTime = adjustedEnd
                                        viewModel.saveWorkHours()
                                        editingWorkHour = nil
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.blue.opacity(0.3))
            .navigationTitle("KDJ-Projects \(viewModel.currentYear())")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadWorkHours()
            }
        }
    }
}


#Preview {
    ContentView()
}


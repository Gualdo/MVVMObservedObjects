//
//  ContentView.swift
//  MVVMObservedObjects
//
//  Created by De La Cruz, Eduardo on 08/01/2020.
//  Copyright © 2020 De La Cruz, Eduardo. All rights reserved.
//

import SwiftUI

let apiUrl = "https://api.letsbuildthatapp.com/static/courses.json"

struct Course: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let price: Int
}

class CoursesViewModel: ObservableObject {
    
    @Published var messages = "Messages inside observable object"
    @Published var courses: [Course] = [
        .init(name: "Course 1", price: 0),
        .init(name: "Course 2", price: 0),
        .init(name: "Course 3", price: 0)
    ]
    
    func fetchCourses() {
        // Fetch json and decode and update some array property
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) {data, resp, err in
            // Make sure to check error / resp
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    self.courses = try JSONDecoder().decode([Course].self, from: data)
                } catch {
                    print("Fail to decode JSON: ", error)
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    
    @ObservedObject var coursesVM = CoursesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(coursesVM.courses) { course in
                            Text(course.name)
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .padding(.bottom, 4)
                            Text("Price: $\(course.price)")
                                .padding(.bottom, 16)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    Spacer()
                }
            }
            .navigationBarTitle("Courses")
            .navigationBarItems(trailing:
                Button(action: {
                    print("Fetching json data")
                    self.coursesVM.fetchCourses()
                }, label: {
                    Text("Fetch Courses")
                })
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

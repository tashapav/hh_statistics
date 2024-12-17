//
//  ContentView.swift
//  hhSwiftUI
//

import SwiftUI

struct ContentView: View {
    @State private var inputWord: String = ""
    @State private var displayedWord: String = ""
    @State private var dataChart1: [String: Int] = [:]
    @State private var countChart1 = 0
    @State private var dataChart2: [String: Int] = [:]
    @State private var countChart2 = 0
    @State private var dataChart3: [String: Int] = [:]
    @State private var countChart3 = 0
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                TextField("Вакансия", text: $inputWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    fetchVacancy()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Поиск")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding([.horizontal])

            if !displayedWord.isEmpty {
                Text("Вакансия: \(displayedWord)")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(.horizontal)
            }

            
            if !dataChart1.isEmpty && !dataChart2.isEmpty && !dataChart3.isEmpty {
                ScrollView(.horizontal) {
                    Text("Распределение вакансий по опыту")
                        .font(.caption)
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(dataChart1.sorted(by: { $0.0 < $1.0 }), id: \ .0) { vacancyAttribute, vacancyCount in
                            VStack {
                                Text("\(vacancyCount * 100 / countChart1) %")
                                    .font(.footnote)

                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: 20, height: CGFloat(vacancyCount * 100 / countChart1))

                                Text(String(vacancyAttribute))
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(height: 135)
                    .padding()
                }
                ScrollView(.horizontal) {
                    Text("Распределение вакансий по запрате")
                        .font(.caption)
                    HStack(alignment: .bottom, spacing: 25) {
                        ForEach(dataChart2.sorted(by: { $0.0 < $1.0 }), id: \ .0) { vacancyAttribute, vacancyCount in
                            VStack {
                                Text("\(vacancyCount * 100 / countChart2) %")
                                    .font(.footnote)

                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: 20, height: CGFloat(vacancyCount * 100 / countChart2))

                                Text(String(vacancyAttribute))
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(height: 135)
                    .padding()
                }
                ScrollView(.horizontal) {
                    Text("Распределение вакансий по городам")
                        .font(.caption)
                    HStack(alignment: .bottom, spacing: 65) {
                        ForEach(dataChart3.sorted(by: { $0.0 < $1.0 }), id: \ .0) { vacancyAttribute, vacancyCount in
                            VStack {
                                Text("\(vacancyCount * 100 / countChart3) %")
                                    .font(.footnote)

                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: 20, height: CGFloat(vacancyCount * 100 / countChart3))

                                Text(String(vacancyAttribute))
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(height: 135)
                    .padding()
                }
            } else {
                Text("Введите вакансию и нажмите кнопку поиска")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }

   
    private func fetchVacancy() {
        guard !inputWord.isEmpty else { return }

        displayedWord = inputWord
        isLoading = true

        let urlString = "http://127.0.0.1:8000/get_vacancies?search_text=\(inputWord)"
        //let urlString = "http://127.0.0.1:8000/get_vacancies_test"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        inputWord = ""

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    print("Ошибка запроса: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Нет данных в ответе")
                    return
                }

                do {
                    let frequencies = try JSONDecoder().decode([ResponseData].self, from: data)
                    print(frequencies)
                    dataChart1 = ["Нет опыта": 0, "От 1 года до 3 лет": 0, "От 3 до 6 лет": 0, "Более 6 лет": 0,]
                    countChart1 = 0
                    dataChart2 = ["До 100": 0, "От 100 до 200": 0, "От 200 до 300": 0, "От 300": 0]
                    countChart2 = 0
                    dataChart3 = ["Москва": 0, "Санкт-Петербург": 0, "Другие": 0]
                    countChart3 = 0
                    
                    for item in frequencies {
                        dataChart1[item.workExperience]! += 1
                        countChart1 += 1
                        if item.salary != nil {
                            countChart2 += 1
                            if item.salary! >= 300000 {
                                dataChart2["От 300"]! += 1
                            } else if item.salary! >= 200000 {
                                dataChart2["От 200 до 300"]! += 1
                            } else if item.salary! >= 100000 {
                                dataChart2["От 100 до 200"]! += 1
                            } else {
                                dataChart2["До 100"]! += 1
                            }
                        }
                        
                        countChart3 += 1
                        if item.city == "Москва" {
                            dataChart3["Москва"]! += 1
                        } else if item.city == "Санкт-Петербург" {
                            dataChart3["Санкт-Петербург"]! += 1
                        } else {
                            dataChart3["Другие"]! += 1
                        }
                    }
                } catch {
                    print("Ошибка декодирования данных: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

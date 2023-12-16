//
//  ContentView.swift
//  hydesk
//
//  Created by Michael Pulliam on 12/16/23.
//

import SwiftUI

struct ContentView: View {
	@AppStorage("api_key") private var api_key: String = ""
	@AppStorage("server_ip") private var server_ip: String = ""
	@State private var tags: String = ""
	@State private var search_results: [Int] = []
	@State private var is_presented = false
	@State private var selected_image: URL = URL(string: "https://www.example.org/")!
	
    var body: some View {
		GeometryReader{ proxy in
			let size = proxy.size
			
			
			VStack {
				HStack {
					TextField("Quoted, comma separated tags...", text: $tags)
						.onSubmit {
							search()
						}
					Button("Search", action: search)
				}
				ScrollView {
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 5) {
						ForEach(search_results, id: \.self) {
							let url_string = "http://" + server_ip + "/get_files/thumbnail?file_id=" + String($0) + "&Hydrus-Client-API-Access-Key=" + api_key
							let url_full_string = "http://" + server_ip + "/get_files/file?file_id=" + String($0) + "&Hydrus-Client-API-Access-Key=" + api_key
							let url = URL(string: url_string)!
							let url_full = URL(string: url_full_string)!
							Button(action: {
								self.selected_image = url_full
								is_presented.toggle()
							}, label: {
								AsyncImage(url: url) {
									image in image
										.resizable().scaledToFit()
								} placeholder: {
									ProgressView()
								}
							}).buttonStyle(.plain)
						}
					}
				}
				Spacer()
			}.padding()
				.sheet(isPresented: $is_presented) {
					
					Button(action: {
						is_presented.toggle()
					}, label: {
						AsyncImage(url: selected_image) {
							image in image
								.resizable()
						} placeholder: {
							ProgressView()
						}.scaledToFit()
					}).buttonStyle(.plain).frame(minWidth: size.width, minHeight: size.height)
				}
		}
		
    }
	
	func search() {
		tags = "[" + tags + "]"
		let url = URL(string: "http://" + server_ip + "/get_files/search_files?tags=" + tags.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
		var request = URLRequest(url: url)
		request.setValue(api_key, forHTTPHeaderField: "Hydrus-Client-API-Access-Key")
		let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
			if let data = data {
				search_results = try! JSONDecoder().decode(SearchFilesResponse.self, from: data).file_ids
			}
		}
		task.resume()
	}
}

struct SearchFilesResponse: Decodable {
	let file_ids: [Int]
}

#Preview {
    ContentView()
}

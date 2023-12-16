//
//  SettingsView.swift
//  hydesk
//
//  Created by Michael Pulliam on 12/16/23.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage("api_key") private var api_key: String = ""
	@AppStorage("server_ip") private var server_ip: String = ""
    var body: some View {
        VStack {
			HStack {
				Text("Hydrus Server IP: ")
				TextField("", text: $server_ip)
				Button("Get API Key", action: getApiKey)
			}
			HStack {
				Text("API Key: ")
				TextField("", text: $api_key)
			}
			
        }
        .padding()
	}
	
	func getApiKey() {
		let url = URL(string: "http://" + server_ip + "/request_new_permissions?name=hydesk&basic_permissions=[0,1,2,3,4,5,6,7,8,9,10]")!
		let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
			if let data = data {
				api_key = try! JSONDecoder().decode(RequestApiKeyResponse.self, from: data).access_key
			}
		}
		task.resume()
	}
}

struct RequestApiKeyResponse: Decodable {
	let access_key: String
}

#Preview {
    SettingsView()
}

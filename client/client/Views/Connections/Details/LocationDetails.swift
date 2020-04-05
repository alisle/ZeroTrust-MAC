//
//  LocationDetails.swift
//  ZeroTrust FW
//
//  Created by Alex Lisle on 4/2/20.
//  Copyright © 2020 Alex Lisle. All rights reserved.
//

import SwiftUI
import IP2Location

struct NoLocationDetails : View {
    var body: some View {
        VStack {
            Text("Unable to locate any location data")
        }
    }
}

struct FullLocationDetails : View {
    let location : IP2LocationRecord
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(location.country!)")
                .bold()
                .font(.title)
                .padding(.init(top: 2, leading: 0, bottom: 5, trailing: 0))

            if location.city != nil {
                Text("\(location.city!), \(location.region!), \(location.zipCode!)")
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Text("Longitude:\(location.longitude!)")
                    .font(.caption)
                    .opacity(0.75)
                    .padding(.init(top: 0, leading: 0, bottom: 5, trailing: 5))

                Text("Latitude: \(location.latitude!)")
                    .font(.caption)
                    .opacity(0.75)

            }
            Spacer()
        }
    }
}

struct LocalLocationDetails : View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Local IP Address")
                .bold()
                .font(.title)
                .padding(.init(top: 2, leading: 0, bottom: 5, trailing: 0))

            Text("You should probably know the locatiob better than I?")
                .font(.caption)
                .opacity(0.75)

            Spacer()
        }

    }
}
struct LocationDetails: View {
    let connection : Connection
    var body: some View {
        VStack {
            if connection.location == nil {
                NoLocationDetails()
            } else if connection.location!.iso! != "-" {
                FullLocationDetails(location: connection.location!)
            } else {
                LocalLocationDetails()
            }
        }
    }
}

struct LocationDetails_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("No Location Record")
            LocationDetails(connection: generateTestConnection(direction: .outbound))
            Spacer()
            Text("Location Record")
            LocationDetails(connection: generateTestConnection(direction: .outbound, includeLocation: true))
            Spacer()
            Text("Local Record")
            LocalLocationDetails()
        }
    }
}

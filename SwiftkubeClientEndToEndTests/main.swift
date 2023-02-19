//
//  main.swift
//  SwiftkubeClientEndToEndTests
//
//  Created by Thomas Horrobin on 14/02/2023.
//

import Foundation
import SwiftkubeClient

if let client = KubernetesClient() {

    print("deployments:")
    let deployments = try await client.appsV1.deployments.list(in: .default)
    for deployment in deployments {
        print(deployment.name ?? "dumb dumb super error")
    }
    
    print("cronjobs:")
    let cronjobs = try await client.batchV1.cronJobs.list(in: .default)
    for cronjob in cronjobs {
        print(cronjob.name ?? "dumb dumb super error")
        let newJob = try cronjob.generateJob()
        let r = try await client.batchV1.jobs.create(in: .default, newJob)
        print(r.name!)
    }
    
    try client.syncShutdown()
}

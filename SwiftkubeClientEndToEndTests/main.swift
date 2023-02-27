//
//  main.swift
//  SwiftkubeClientEndToEndTests
//
//  Created by Thomas Horrobin on 14/02/2023.
//

import Foundation
import SwiftkubeClient
import SwiftkubeModel

if let client = KubernetesClient(fromURL: URL(filePath: "/Users/thomashorrobin/Developer/SwiftkubeClientEndToEndTests/SwiftkubeClientEndToEndTests/kube-cmd-kubeconfig.yaml")) {

    print("deployments:")
    let deployments = try await client.appsV1.deployments.list(in: .default)
    for deployment in deployments {
        print(deployment.name ?? "dumb dumb super error")
    }
    
//    var jobName: String
    
    print("cronjobs:")
    let cronjobs = try await client.batchV1.cronJobs.list(in: .default)
    for cronjob in cronjobs {
        print(cronjob.name ?? "dumb dumb super error")
        let newJob = try cronjob.generateJob()
        let r = try await client.batchV1.jobs.create(in: .default, newJob)
        print(r.name ?? "hi")
//        jobName = r.name!
    }
//    let xhjshdbc = FieldSelectorRequirement.eq(["ownerReferences":"uid"])
//    let x: ListOption = ListOption.fieldSelector(xhjshdbc)
    
    let pods = try await client.pods.list(in: .default)
    for pod in pods {
        print(pod.metadata?.ownerReferences?.first?.name ?? "dumb system")
    }
    
    try client.syncShutdown()
} else {
    print("big silly error")
}


enum createJobFromCronjobErrors: Error {
    case jobSpecDoesntExist
    case jobMetadataDoesntExist
    case cronjobNameDoesntExist
}

public extension batch.v1.CronJob {
    func generateJob() throws -> batch.v1.Job {
        guard let jobTemplateSpec = spec?.jobTemplate.spec else { throw createJobFromCronjobErrors.jobSpecDoesntExist }
        guard let name = name else { throw createJobFromCronjobErrors.cronjobNameDoesntExist }
        let jobName = "\(name)-manual-\(GenerateRandomHash())"
        guard let metadata = metadata else { throw createJobFromCronjobErrors.jobMetadataDoesntExist }
        var existingMetadata = metadata
        existingMetadata.name = jobName
        var job = batch.v1.Job()
        existingMetadata.resourceVersion = nil
        job.spec = jobTemplateSpec
        job.metadata = existingMetadata
        return job
    }
}
/// GenerateRandomHash returns a three character. I
func GenerateRandomHash() -> String {
    // We omit vowels from the set of available characters to reduce the chances
    // of "bad words" being formed.
    let alphanums = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z", "2", "4", "5", "6", "7", "8", "9"]
    var seedAlphanum = alphanums.randomElement()!
    var slug = seedAlphanum
    var neededAlphanums = 2
    while neededAlphanums > 0 {
        let nextAlphanum = alphanums.randomElement()!
        if nextAlphanum != seedAlphanum {
            seedAlphanum = nextAlphanum
            slug = slug + nextAlphanum
            neededAlphanums -= 1
        }
    }
    return slug
}

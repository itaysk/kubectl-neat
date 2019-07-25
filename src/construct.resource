{ 
    apiVersion, 
    kind, 
    metadata: { 
        name: .metadata.name, 
        labels: (.metadata.labels // {}), 
        annotations: (.metadata.annotations // {})
    }, 
    spec 
}
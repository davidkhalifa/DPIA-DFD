# Ensure the svg_exports directory exists
if (!(Test-Path -Path "svg_exports")) {
    New-Item -ItemType Directory -Path "svg_exports" | Out-Null
}

# Create subdirectories for different diagram types
$subdirs = @("dfd", "sequence")
foreach ($subdir in $subdirs) {
    $path = "svg_exports\$subdir"
    if (!(Test-Path -Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

$files = @(
    "C:\DPIA DFD\generated md files\data_retention_deletion.md",
    "C:\DPIA DFD\generated md files\external_data_sharing.md",
    "C:\DPIA DFD\generated md files\high_level_overview.md",
    "C:\DPIA DFD\generated md files\transaction_processing_detail.md",
    "C:\DPIA DFD\generated md files\user_journey_perspective.md"
)

foreach ($file in $files) {
    # Get the base name without extension
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    
    # Create a temporary file to hold just the Mermaid content
    $content = Get-Content $file -Raw
    
    # Find all Mermaid diagram blocks in the file
    $mermaidBlocks = [regex]::Matches($content, '```mermaid\s*([\s\S]*?)```')
    
    if ($mermaidBlocks.Count -eq 0) {
        Write-Host "No mermaid content found in $file"
        continue
    }
    
    # Process each Mermaid block
    for ($i = 0; $i -lt $mermaidBlocks.Count; $i++) {
        $mermaidContent = $mermaidBlocks[$i].Groups[1].Value.Trim()
        
        # Determine if this is a DFD (flowchart) or sequence diagram based on content
        $diagramType = if ($mermaidContent -match "flowchart") { "dfd" } else { "sequence" }
        
        # Define output file path based on diagram type
        $outputFile = "svg_exports\$diagramType\$baseName"
        if ($mermaidBlocks.Count -gt 1) {
            # Add index to filename if there are multiple diagrams of the same type
            $outputFile += "_$($i+1)"
        }
        $outputFile += ".svg"
        
        # Apply color optimizations for better readability
        if ($diagramType -eq "dfd") {
            # Update the classes to use darker colors for better visibility (for DFDs)
            $mermaidContent = $mermaidContent -replace "classDef external fill:#f9f,", "classDef external fill:#f8e0ff,"
            $mermaidContent = $mermaidContent -replace "classDef process fill:#bbf,", "classDef process fill:#d0e0ff,"
            $mermaidContent = $mermaidContent -replace "classDef datastore fill:#dfd,", "classDef datastore fill:#e0ffe0,"
            $mermaidContent = $mermaidContent -replace "classDef deletion fill:#fdd,", "classDef deletion fill:#ffe0e0,"
            $mermaidContent = $mermaidContent -replace "classDef anonymized fill:#cfc,", "classDef anonymized fill:#d0ffd0,"
            $mermaidContent = $mermaidContent -replace "classDef sensitiveFlow fill:#fcb,", "classDef sensitiveFlow fill:#ffe0b0,"
            $mermaidContent = $mermaidContent -replace "classDef legalFlow fill:#cff,", "classDef legalFlow fill:#d0ffff,"
            $mermaidContent = $mermaidContent -replace "classDef sensitiveData fill:#fcb,", "classDef sensitiveData fill:#ffe0b0,"
            $mermaidContent = $mermaidContent -replace "classDef encrypted fill:#cfc,", "classDef encrypted fill:#d0ffd0,"
            
            # Make all stroke colors darker for better contrast
            $mermaidContent = $mermaidContent -replace "stroke:#333,", "stroke:#000,"
        } else {
            # Optimize sequence diagrams if needed
            # Any sequence diagram-specific optimizations would go here
        }
        
        # Write the processed content to a temporary file
        $mermaidContent | Out-File -FilePath "temp_diagram.mmd" -Encoding UTF8
        
        Write-Host "Generating $diagramType SVG for $baseName (diagram $($i+1) of $($mermaidBlocks.Count))..."
        # Use -b white for white background and don't use config file
        mmdc -i "temp_diagram.mmd" -o $outputFile -b white -w 1200
    }
}

# Clean up the temporary files
if (Test-Path "temp_diagram.mmd") {
    Remove-Item "temp_diagram.mmd"
}

Write-Host "All SVGs generated with improved readability in the svg_exports directory"

# Ensure the svg_exports directory exists
if (!(Test-Path -Path "svg_exports")) {
    New-Item -ItemType Directory -Path "svg_exports" | Out-Null
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
    $outputFile = "svg_exports\$baseName.svg"
    
    # Create a temporary file to hold just the Mermaid content
    $content = Get-Content $file -Raw
    # Extract content between ```mermaid and ``` markers
    if ($content -match '```mermaid\s*([\s\S]*?)```') {
        $mermaidContent = $matches[1].Trim()
        
        # Update the classes to use darker colors for better visibility
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
          $mermaidContent | Out-File -FilePath "temp_diagram.mmd" -Encoding UTF8
        
        Write-Host "Generating SVG for $file with improved readability..."
        # Use -b white for white background and don't use config file
        mmdc -i "temp_diagram.mmd" -o $outputFile -b white
    } else {
        Write-Host "No mermaid content found in $file"
    }
}

# Clean up the temporary files
if (Test-Path "temp_diagram.mmd") {
    Remove-Item "temp_diagram.mmd"
}

Write-Host "All SVGs generated with improved readability in the svg_exports directory"

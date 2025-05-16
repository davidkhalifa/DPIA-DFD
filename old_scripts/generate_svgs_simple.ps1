# filepath: c:\DPIA DFD\generate_svgs_simple.ps1
$files = @(
    "data_retention_deletion.md",
    "external_data_sharing.md",
    "high_level_overview.md",
    "transaction_processing_detail.md"
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
        
        # Update the classes to use darker colors for better visibility on white background
        $mermaidContent = $mermaidContent -replace "classDef external fill:#f9f,", "classDef external fill:#ffe6ff,"
        $mermaidContent = $mermaidContent -replace "classDef process fill:#bbf,", "classDef process fill:#e6e6ff,"
        $mermaidContent = $mermaidContent -replace "classDef datastore fill:#dfd,", "classDef datastore fill:#e6ffe6,"
        $mermaidContent = $mermaidContent -replace "classDef deletion fill:#fdd,", "classDef deletion fill:#ffe6e6,"
        $mermaidContent = $mermaidContent -replace "classDef anonymized fill:#cfc,", "classDef anonymized fill:#e6ffe6,"
        $mermaidContent = $mermaidContent -replace "classDef thirdPartySystem fill:#f9f,", "classDef thirdPartySystem fill:#ffe6ff,"
        $mermaidContent = $mermaidContent -replace "classDef microsoftSystem fill:#bbf,", "classDef microsoftSystem fill:#e6e6ff,"
        $mermaidContent = $mermaidContent -replace "classDef sensitiveFlow fill:#fcb,", "classDef sensitiveFlow fill:#fff2e6,"
        $mermaidContent = $mermaidContent -replace "classDef legalFlow fill:#cff,", "classDef legalFlow fill:#e6ffff,"
        $mermaidContent = $mermaidContent -replace "classDef sensitiveData fill:#fcb,", "classDef sensitiveData fill:#fff2e6,"
        $mermaidContent = $mermaidContent -replace "classDef encrypted fill:#cfc,", "classDef encrypted fill:#e6ffe6,"
        
        # Make all stroke colors darker for better contrast
        $mermaidContent = $mermaidContent -replace "stroke:#333,", "stroke:#000,"
        
        $mermaidContent | Out-File -FilePath "temp_diagram.mmd" -Encoding UTF8
        
        Write-Host "Generating SVG for $file with improved readability..."
        mmdc -i "temp_diagram.mmd" -o $outputFile -b white
    } else {
        Write-Host "No mermaid content found in $file"
    }
}

# Clean up the temporary file
if (Test-Path "temp_diagram.mmd") {
    Remove-Item "temp_diagram.mmd"
}

Write-Host "All SVGs generated with improved readability in the svg_exports directory"

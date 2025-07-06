#!/bin/bash

# This Bash script retrieves store inventory data from Budni (German drugstore chain)
# for a specific product ID. It downloads JSON data from their stock API, converts it
# to CSV format for data analysis, and generates a interactive map showing all store
# locations where the product is available.

# Example: Windel Gr. 1 Newborn
# Product website: https://www.budni.de/sortiment/produkte/4558670009
# Product ID: 4558670009

# How to Find the Product ID

# Product: Windel Gr. 1 Newborn
# URL: https://www.budni.de/sortiment/produkte/4558670009
# Product ID: 4558670009

# https://www.budni.de/sortiment/produkte/[PRODUCT_ID]
#                                         ^^^^^^^^^^^^
#                                         This is your Product ID

# bash budni.sh 4558670009


# Function to display usage
usage() {
    echo "Usage: $0 <product_id>"
    echo "Example: $0 6599602003"
    exit 1
}

# Function to check if required tools are installed
check_dependencies() {
    local missing_tools=()

    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi

    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo "Error: Missing required tools: ${missing_tools[*]}"
        echo "Please install them using your package manager:"
        echo "  Ubuntu/Debian: sudo apt-get install curl jq"
        echo "  macOS: brew install curl jq"
        exit 1
    fi
}

# Function to create HTML map
create_html_map() {
    local product_id="$1"
    local json_file="$2"
    local html_file="budni_map_${product_id}.html"

    echo "Creating HTML map: $html_file"

    # Extract store data for JavaScript
    local stores_js=$(jq -r '.data[] | {
        id: .id,
        name: .name,
        hours: .workingDaysSummary,
        address: (.contact.streetAndNumber + ", " + .contact.zip + " " + .contact.city),
        lat: .contact.latitude,
        lng: .contact.longitude
    }' "$json_file" | jq -s .)

    # Create HTML file
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Budni Stores Map - Product ID: $product_id</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body, html {
            height: 100%;
            font-family: Arial, sans-serif;
        }
        
        #map {
            height: 100vh;
            width: 100vw;
        }
        
        .leaflet-popup-content {
            margin: 8px 12px;
            line-height: 1.4;
        }
        
        .popup-title {
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .popup-address {
            margin-bottom: 3px;
        }
        
        .popup-hours {
            color: #666;
            font-size: 13px;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <div id="map"></div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Store data from JSON
        const stores = $stores_js;
        // Hamburg
        const centerLat = 53.55;
        const centerLng = 10;

        // Initialize map
        const map = L.map('map').setView([centerLat, centerLng], 11);

        // Add OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        // Add markers for each store
        const markers = [];
        stores.forEach(store => {
            const popupContent = \`
                <div class="popup-title">\${store.name}</div>
                <div class="popup-address">\${store.address}</div>
                <div class="popup-hours">\${store.hours}</div>\`;

            const marker = L.marker([store.lat, store.lng])
                .addTo(map)
                .bindPopup(popupContent);

            markers.push(marker);
        });
    </script>
</body>
</html>
EOF

    echo "HTML map created: $html_file"
    echo "Open $html_file in your web browser to view the map"
}

# Function to download and parse JSON
download_and_parse() {
    local product_id="$1"
    local url="https://www.budni.de/api/stocks/api/v1/Stocks/article-id/${product_id}/markets"
    local json_file="budni_data_${product_id}.json"
    local csv_file="budni_stores_${product_id}.csv"

    echo "Downloading data for product ID: $product_id"
    echo "URL: $url"

    # Download JSON data
    if ! curl -s -o "$json_file" "$url"; then
        echo "Error: Failed to download data from URL"
        exit 1
    fi

    # Check if file was downloaded and is not empty
    if [ ! -s "$json_file" ]; then
        echo "Error: Downloaded file is empty or doesn't exist"
        exit 1
    fi
    
    # Validate JSON format
    if ! jq empty "$json_file" 2>/dev/null; then
        echo "Error: Downloaded data is not valid JSON"
        echo "Content of downloaded file:"
        cat "$json_file"
        exit 1
    fi

    # Check if data array exists and has content
    local data_count=$(jq '.data | length' "$json_file" 2>/dev/null)
    if [ "$data_count" = "null" ] || [ "$data_count" = "0" ]; then
        echo "Warning: No store data found for product ID $product_id"
        echo "API Response:"
        cat "$json_file"
        exit 1
    fi

    echo "Found $data_count store(s) with this product"

    # Create CSV header
    echo "ID,Name,Working Hours,Street and Number,ZIP,City,Latitude,Longitude" > "$csv_file"

    # Parse JSON and convert to CSV
    jq -r '.data[] | [
        .id,
        .name,
        .workingDaysSummary,
        .contact.streetAndNumber,
        .contact.zip,
        .contact.city,
        .contact.latitude,
        .contact.longitude
    ] | @csv' "$json_file" >> "$csv_file"

    # Create HTML map
    create_html_map "$product_id" "$json_file"

    echo "CSV file created: $csv_file"
    echo "JSON file saved: $json_file"
    echo ""
    echo "Total stores found: $(($(wc -l < "$csv_file") - 1))"
    echo ""
    echo "Files created:"
    echo "  📊 CSV: $csv_file"
    echo "  📄 JSON: $json_file"
    echo "  🗺️ HTML Map: budni_map_${product_id}.html"
}

# Main script execution
main() {
    # Check if product ID is provided
    if [ $# -eq 0 ]; then
        echo "Error: Product ID is required"
        usage
    fi

    local product_id="$1"

    # Validate product ID (should be numeric)
    if ! [[ "$product_id" =~ ^[0-9]+$ ]]; then
        echo "Error: Product ID should be numeric"
        usage
    fi

    # Check dependencies
    check_dependencies

    # Download and parse data
    download_and_parse "$product_id"
}

# Run main function with all arguments
main "$@"

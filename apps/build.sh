#!/bin/bash

output_dir=".artifacts"

mkdir -p "$output_dir"
rm -rf $output_dir/*.zip

pushd apps

dotnet publish --output "bin/publish"

find ./src -iname *.csproj | while read line; do

    project_name=$(basename "$line" .csproj)

    publish_path="./src/$project_name/bin/publish"
    output_zip="../$output_dir/$project_name.zip"

    7z a "$output_zip" "$publish_path/*" > /dev/null

done

popd

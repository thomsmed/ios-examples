# Multiple app flavours using build Configurations

## Configure custom variants for Debug and Release configurations:
- Project -> Info -> Configurations
- Duplicate Debug configuration when creating custom Debug variants (e.g. Debug-Develop, Debug-Prod)
- Duplicate Release configuration when creating custom Release variants (e.g. Release-Develop, Release-Prod)

## Configure custom build settings (exposed as environment variables during build time):
- Project wide settings: Project -> Build Settings -> Add new setting ("+"-sign)
- Target wide settings: Project -> Select target -> Add new setting ("+"-sign)

## Select build settings based on build configurations
Product Bundle Identifier:
- Project -> Select target -> Product Bundle Identifier -> For each build configuration, specify the Product Bundle Identifier 

Product Name
- Project -> Select target -> Product Name -> For each build configuration, specify the Product Name

## Run custom scripts to copy app flavour dependent files
- Project -> Select target -> Build phases -> Add new phase (Run Script Phase) -> Customise the script to copy over app flavour specific files to a path known to the Xcode project

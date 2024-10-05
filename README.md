# xcstrings-migrator

Convert legacy strings files to xcstrings (String Catalog).

## Help

```sh
OVERVIEW: A tool to migrate the legacy strings file to xcstrings file.

USAGE: xcstrings-migrator [--source-language <source-language>] --path <path> ... --output-directory <output-directory> [--verbose]

OPTIONS:
  -l, --source-language <source-language>
                          Source language of the xcstrings file. (default: en)
  -p, --path <path>       Path to the lproj directory.
  -o, --output-directory <output-directory>
                          Path to the directory where you want to save the xcstrings file.
  -v, --verbose           Do not output warnings.
  --version               Show the version.
  -h, --help              Show help information.
```

## Usage

```sh
git clone https://github.com/Kyome22/xcstrings-migrator.git
cd xcstrings-migrator
swift run xcstrings-migrator -output-directory ~/result -path ~/original/en.lproj -path ~/original/ja.lproj
```

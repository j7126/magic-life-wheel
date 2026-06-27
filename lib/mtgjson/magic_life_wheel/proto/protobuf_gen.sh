SRC_DIR="./"
for f in ./*.proto; do
    protoc -I=$SRC_DIR --dart_out="../generated" "$SRC_DIR/$f"
done
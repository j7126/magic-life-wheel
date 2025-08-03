SRC_DIR="./"
protoc -I=$SRC_DIR --dart_out=$SRC_DIR "$SRC_DIR/card_set.proto"
protoc -I=$SRC_DIR --dart_out=$SRC_DIR "$SRC_DIR/all_set_cards.proto"
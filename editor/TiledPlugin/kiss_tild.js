/*
    {
        width : 16,
        height : 16,
        block_width : 16,
        block_height : 16,
        block_attributes : [
            {
                id : 1,
                attributes : {
                    key : value
                }
            }
        ]
    }
    */
tiled.registerTilesetFormat("Ling_2121", {
    name: "Kiss的Tileset格式",
    extension: "tileset.json",
    write: (tileset, fileName) => {
        let file = new TextFile(fileName+".json", TextFile.WriteOnly)
        let datas = {
            "name": tileset.name,
            "tile_width": tileset.tileWidth,
            "tile_height": tileset.tileHeight,
            "tiles": [

            ],
        }

        for (var i = 0; i < tileset.tileCount; i++) {
            var tile = tileset.tile(i);
            var properties = tile.properties();
            var attributes = {
                "name" : properties["name"]
            }

            if(attributes.name == null)
            {
                attributes.name = i
            }

            var item_number = 0;
            for (var key in properties) {
                attributes[key] = properties[key];
                item_number++;
            }
            datas.tiles.push(attributes)
        }

        let json_string = JSON.stringify(datas)
        file.write(json_string)
        file.commit()
    }
})
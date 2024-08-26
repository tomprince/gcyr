package argent_matter.gcyr.common.data;

import argent_matter.gcyr.GCyR;
import argent_matter.gcyr.api.registries.GCyRRegistries;
import com.gregtechceu.gtceu.api.data.DimensionMarker;
import com.gregtechceu.gtceu.utils.FormattingUtil;
import com.tterrag.registrate.util.entry.BlockEntry;
import net.minecraft.client.renderer.block.model.BlockModel;
import net.minecraft.world.level.block.Block;

import static com.gregtechceu.gtceu.common.data.GTDimensionMarkers.createAndRegister;

@SuppressWarnings("unused")
public class GCYRDimensionMarkers {

    public static final BlockEntry<Block> LUNA_MARKER = createMarker("luna");
    public static final BlockEntry<Block> MARS_MARKER = createMarker("mars");
    public static final BlockEntry<Block> MERCURY_MARKER = createMarker("mercury");
    public static final BlockEntry<Block> VENUS_MARKER = createMarker("venus");

    public static final DimensionMarker LUNA = createAndRegister(GCyR.id("luna"), 1,
            () -> LUNA_MARKER, null);
    public static final DimensionMarker MARS = createAndRegister(GCyR.id("mars"), 2,
            () -> MARS_MARKER, null);
    public static final DimensionMarker MERCURY = createAndRegister(GCyR.id("mercury"), 2,
            () -> MERCURY_MARKER, null);
    public static final DimensionMarker VENUS = createAndRegister(GCyR.id("venus"), 2,
            () -> VENUS_MARKER, null);

    private static BlockEntry<Block> createMarker(String name) {
        return GCyRRegistries.REGISTRATE.block("%s_marker".formatted(name), Block::new)
                .lang(FormattingUtil.toEnglishName(name))
                .blockstate((ctx, prov) -> prov.simpleBlock(ctx.get(), prov.models().cube(ctx.getName(),
                                prov.modLoc("block/dim_markers/%s/down".formatted(name)),
                                prov.modLoc("block/dim_markers/%s/up".formatted(name)),
                                prov.modLoc("block/dim_markers/%s/north".formatted(name)),
                                prov.modLoc("block/dim_markers/%s/south".formatted(name)),
                                prov.modLoc("block/dim_markers/%s/east".formatted(name)),
                                prov.modLoc("block/dim_markers/%s/west".formatted(name)))
                        .texture("particle", "#north")
                        .guiLight(BlockModel.GuiLight.FRONT)))
                .simpleItem()
                .register();
    }

    public static void init() {}
}
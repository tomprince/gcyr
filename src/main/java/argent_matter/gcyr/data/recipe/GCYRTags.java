package argent_matter.gcyr.data.recipe;

import argent_matter.gcyr.api.data.tag.GCYRTagUtil;
import com.gregtechceu.gtceu.api.data.tag.TagUtil;
import net.minecraft.core.registries.Registries;
import net.minecraft.tags.TagKey;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.item.Item;
import net.minecraft.world.level.biome.Biome;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.material.Fluid;

public class GCYRTags {
    // Item
    public static final TagKey<Item> SATELLITES = GCYRTagUtil.createModItemTag("satellites");
    public static final TagKey<Item> SPACESUIT_ARMOR = GCYRTagUtil.createModItemTag("is_spacesuit");
    public static final TagKey<Item> FREEZE_RESISTANT = GCYRTagUtil.createModItemTag("freeze_resistant");
    public static final TagKey<Item> HEAT_RESISTANT = GCYRTagUtil.createModItemTag("heat_resistant");

    // Block
    public static final TagKey<Block> MOON_ORE_REPLACEABLES = TagUtil.createBlockTag("moon_ore_replaceables");
    public static final TagKey<Block> MARS_ORE_REPLACEABLES = TagUtil.createBlockTag("mars_ore_replaceables");
    public static final TagKey<Block> INFINIBURN_SPACE = GCYRTagUtil.createModBlockTag("infiniburn_space");
    public static final TagKey<Block> BLOCKS_FLOOD_FILL = GCYRTagUtil.createModBlockTag("blocks_flood_fill");
    public static final TagKey<Block> PASSES_FLOOD_FILL = GCYRTagUtil.createModBlockTag("passes_flood_fill");
    public static final TagKey<Block> MINEABLE_WITH_WRENCH = GCYRTagUtil.createBlockTag("mineable/wrench");

    // Fluid
    public static final TagKey<Fluid> VEHICLE_FUELS = GCYRTagUtil.createModFluidTag("vehicle_fuels");
    public static final TagKey<Fluid> OXYGEN = TagUtil.createFluidTag("oxygen");

    // Biome
    public static final TagKey<Biome> IS_SPACE = GCYRTagUtil.createModTag(Registries.BIOME, "is_space");
    public static final TagKey<Biome> IS_MOON = GCYRTagUtil.createModTag(Registries.BIOME, "is_moon");
    public static final TagKey<Biome> IS_MERCURY = GCYRTagUtil.createModTag(Registries.BIOME, "is_mercury");
    public static final TagKey<Biome> IS_MARS = GCYRTagUtil.createModTag(Registries.BIOME, "is_mars");
    public static final TagKey<Biome> IS_VENUS = GCYRTagUtil.createModTag(Registries.BIOME, "is_venus");

    // Entity
    public static final TagKey<EntityType<?>> IGNORE_OXYGEN = GCYRTagUtil.createModTag(Registries.ENTITY_TYPE, "ignore_oxygen");
    public static final TagKey<EntityType<?>> IGNORE_TEMPERATURE = GCYRTagUtil.createModTag(Registries.ENTITY_TYPE, "ignore_temperature");
}

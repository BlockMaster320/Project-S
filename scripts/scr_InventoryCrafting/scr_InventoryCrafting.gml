//Function checking the slots in the crafting grid && updating the crafting products accordingly.
function crafting_update_products(_craftingGrid)
{
	//Create a Map of Resources (Items That Can Be Used for Crafting)
	var _resourceMap = ds_map_create();
	var _materialList = ds_list_create();
	for (var _r = 0; _r < ds_grid_height(_craftingGrid); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_craftingGrid); _c ++)
		{
			var _slot = craftingGrid[# _c, _r];
			var _slotItem = id_get_item(_slot.id);
			if (_slot != 0)
			{
				//Add the Slot's Item Data to the resourceMap
				if (is_undefined(_resourceMap[? _slot.id]))
					_resourceMap[? _slot.id] = _slot.itemCount;	//create new key for the item
				else
					_resourceMap[? _slot.id] += _slot.itemCount;	//add the slot's itemCount to an existing key
				
				//Add the Slot to the materialList if It's Material
				if (_slotItem.category == itemCategory.material)
					ds_list_add(_materialList, _slot);
			}
		}
	}
	
	//Create a List of Crafting Products
	var _productList = ds_list_create();
	for (var _id = 0; _id < ITEM_NUMBER; _id ++)	//loop through all the existing items
	{
		//Get the Resources Needed to Craft the Item
		var _item = id_get_item(_id);
		var _craftItems = _item.craftItems;
		var _timesCanBeCrafted = infinity;	//how many times the item can be crafted
		var _needsMaterial = false;
		
		//Check if There Are All the Resources Needed in the resourceMap
		for (var _i = 0; _i < array_length(_craftItems); _i ++)	//loop through all the item's craft items
		{
			var _craftItem = _craftItems[_i];
			var _resourceItemCount = _resourceMap[? _craftItem[0]];
			if (!is_undefined(_resourceItemCount))	//check if there's the id needed in the rseourceMap
			{
				_timesCanBeCrafted = min(_timesCanBeCrafted, _resourceItemCount div _craftItem[1]);
				if (_timesCanBeCrafted == 0)
					break;
				if (id_get_item(_craftItem[0]).category == itemCategory.material)
					_needsMaterial = true;
			}
			else 
			{
				_timesCanBeCrafted = 0;
				break;
			}
		}
		
		//Add the Item to the productList
		if (_timesCanBeCrafted != 0)
		{
			//Set the Slot's Attributes
			var _attributes = noone;
			
			//Add an Item That Doesn't Need a Material Item to be Crafted to the productList
			if (!_needsMaterial)
			{
				/*if (_item.category == itemCategory.material)	//give materials some properties for testing
					_attributes = [[9]];*/
				
				var _productItemCount = _timesCanBeCrafted * _item.craftAmount;
				_productItemCount = clamp(_productItemCount, 1, _item.itemLimit);
				ds_list_add(_productList, new Slot(_id, _productItemCount, _attributes));
			}
			
			//Add an Item That Does Need a Material Item to be Crafted to the productList
			else
			{
				//Add a Tool of Every Material in the materialList to the productList
				for (var _i = 0; _i < ds_list_size(_materialList); _i ++)
				{
					var _material = _materialList[| _i];
					_attributes = [_material.properties];
					ds_list_add(_productList, new Slot(_id, 1, _attributes));
				}
			}
		}
	}
	
	//Set the Crafting Products && Delete Data Structures
	obj_Inventory.craftingProducts = _productList;
	ds_map_destroy(_resourceMap);
	ds_list_destroy(_materialList);
}

/// Function updating the the slots in the craftingGrid according to taken crafting products.
function crafting_update_resources(_craftingGrid, _product, _productItemCount)
{
	//Get the Crafring Product Data
	var _timesCrafted = _productItemCount div id_get_item(_product.id).craftAmount;
	var _craftItems = id_get_item(_product.id).craftItems;
	
	//Update the Resources
	for (var _i = 0; _i < array_length(_craftItems); _i ++)	//loop through the items needed to craft the product
	{
		var _craftItem = _craftItems[_i];
		var _resourceItemsNeeded = _craftItem[1] * _timesCrafted;	//get how many items of the product craftItem's ID has to be subtracted from the craftingGrid's slots
		
		for (var _r = 0; _r < ds_grid_height(_craftingGrid); _r ++)	//loop through the inventoryGrid
		{
			for (var _c = 0; _c < ds_grid_width(_craftingGrid); _c ++)
			{
				//Subtract the Needed Items from the Slot
				var _slot = _craftingGrid[# _c, _r];
				if (_slot != 0)
				{
					if (_slot.id == _craftItem[0])
					{
						if (variable_struct_exists(_product, "properties") && variable_struct_exists(_slot, "properties"))
						{
							if (_product.properties != _slot.properties)
								continue;
						}
						
						_resourceItemsNeeded -= _slot.itemCount;
						_slot.itemCount = abs(clamp(_resourceItemsNeeded, - infinity, 0));
						
						if (_slot.itemCount == 0)
							slot_set(_craftingGrid, _c, _r, 0, noone);
						if (_resourceItemsNeeded <= 0) break;
					}
				}
			}
			if (_resourceItemsNeeded <= 0) break;
		}
	}
}

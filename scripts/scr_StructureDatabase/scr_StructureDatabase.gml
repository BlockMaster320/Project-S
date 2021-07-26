/// Script storing information about structures.
/// Specific structure can be optained by its ID using the function.
function id_get_structure(_id)
{
	//Structure Data
	static Tree1 =
	{
		id : 0,
		name : "Tree 1",
		width : 3,
		height : 3,
		structureArray : [[2, 2, 2],
						 [ 2, 5, 2],
						 [ 2, 2, 2]]
	};
	
	static Tree2 =
	{
		id : 1,
		name : "Tree 2",
		width : 5,
		height : 6,
		structureArray : [[noone, 9,	 9,	9,     noone],
						 [ noone, 9,	 9,	9,	   noone],
						 [ 9,	  9,	 9,	9,	   9],
						 [ noone, noone, 2, noone, noone],
						 [ noone, noone, 2, noone, noone],
						 [ noone, noone, 2, noone, noone]]
	};
	
	static Sus =
	{
		id : 2,
		name : "SUS",
		width : 9,
		height : 5,
		structureArray : [[9,	  9,	 noone,	9, noone, 9, noone, 9,	   9],
						 [ 9,	  noone, noone,	9, noone, 9, noone, 9,	   noone],
						 [ 9,	  9,	 noone,	9, noone, 9, noone, 9,	   9],
						 [ noone, 9,	 noone,	9, noone, 9, noone, noone, 9],
						 [ 9,	  9,	 noone,	9, 9,	  9, noone, 9,	   9]]
	};
	
	//Get a Specific Structure By Its ID
	switch(_id)
	{
		case 0:
			return Tree1;
			break;
			
		case 1:
			return Tree2;
			break;
		
		case 2:
			return Sus;
			break;
	}
}

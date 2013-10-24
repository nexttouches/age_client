package nt.lib.serialization.nml
{

	internal final class Encoder
	{

		public function encode(input:Object):String
		{
			var delimiter:String = NML.Delimiter;
			var terminator:String = NML.Terminator;
			var result:Array = [];
			var factory:Class = input.constructor;
			var key:String;
			if (factory == Object || factory == Array)
			{
				for (key in input)
				{
					result.push(key + delimiter + input[key]);
				}
			}
			return result.join(terminator);
		}
	}
}

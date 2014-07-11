package widgets.exInterface.PolluteManager
{

	public class copyObject extends Object
	{
		public function copyObject()
		{
			super();
		}

		import flash.utils.ByteArray;
		import flash.utils.getQualifiedClassName;

		import flash.utils.getDefinitionByName;
		import flash.net.registerClassAlias;


		public static function clone(object:Object):Object
		{

			var qClassName:String=getQualifiedClassName(object);

			var objectType:Class=getDefinitionByName(qClassName) as Class;

			registerClassAlias(qClassName, objectType);

			var copier:ByteArray=new ByteArray();

			copier.writeObject(object);

			copier.position=0;

			return copier.readObject();

		}
	}
}

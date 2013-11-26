package age.data.objectStates
{

	/**
	 * 储存所有可用的状态
	 * @author zhanghaocong
	 *
	 */
	public class ObjectStates
	{
		/**
		 * 攻击状态
		 */
		public static const attack:AttackState = new AttackState;

		/**
		 * 空闲状态
		 */
		public static const idle:IdleState = new IdleState;

		/**
		 * 跑动状态
		 */
		public static const run:RunState = new RunState;

		/**
		 * 行走状态
		 */
		public static const walk:WalkState = new WalkState;

		public function ObjectStates()
		{
		}
	}
}

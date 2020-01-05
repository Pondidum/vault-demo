using System;

namespace ExternalConfiguration
{
	public class UserInfo
	{
		public string Name { get; set; }
		public DateTime? ValidUntil { get; set; }

		public override string ToString()
		{
			if (ValidUntil.HasValue)
			{
				var now = DateTime.Now;
				var expiry = ValidUntil.Value;
				var delta = expiry.Subtract(now);

				return $"{Name} expires in {delta:mm\\:ss}";
			}

			return $"{Name} does not expire";
		}
	}
}

using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class LightningRandomiser : MonoBehaviour
{
	public Lightning[] lightning;

	public void FireRandomLightning()
	{
		if(lightning.Length==0)
			return;
		Lightning l = lightning[Random.Range(0, lightning.Length)];
		if (l == null)
		{
			Debug.LogWarning("Lightning is unassigned", this);
			return;
		}
		l.DoLightning();
	}

	[EditorButton]
	void AssignLightningChildren()
	{
		List<Lightning> l = new List<Lightning>(lightning);
		Lightning[] c = GetComponentsInChildren<Lightning>();
		l.AddRange(c.Where(c2=>!l.Contains(c2)));
		lightning = l.ToArray();
	}
}

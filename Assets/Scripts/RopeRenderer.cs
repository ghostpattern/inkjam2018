using System;
using UnityEngine;
using UnityEngine.Serialization;

[RequireComponent(typeof(LineRenderer))]
public class RopeRenderer : MonoBehaviour
{

	public LineRenderer lineRenderer;
	[EditorOnly]
	public int length = 100;
	public float slack;

	private CableCurve _cableCurve;

	private Transform anchor;
	[FormerlySerializedAs("anchor2")] public Transform secondaryAnchor;
	
	private void Reset()
	{
		lineRenderer = GetComponent<LineRenderer>();
	}

	private void OnEnable()
	{
		if (secondaryAnchor == null)
		{
			Debug.LogWarning("Secondary anchor of Rope is not assigned", this);
			enabled = false;
			return;
		}
		lineRenderer.positionCount = length;
		anchor = transform;
		_cableCurve = new CableCurve();
	}

	[EditorButton]
	void Bake()
	{
		OnEnable();
		Update();
	}

	// Update is called once per frame
	void Update ()
	{
		Vector3 a1 = anchor.position;
		Vector3 a2 = secondaryAnchor.position;
		_cableCurve.start = a1;
		_cableCurve.end = a2;
		_cableCurve.slack = slack;
		_cableCurve.steps = length;
		Vector3[] positions = _cableCurve.Points();
		lineRenderer.SetPositions(positions);
	}

	[Serializable]
	public class CableCurve {
		[SerializeField]
		Vector3 m_start;
		[SerializeField]
		Vector3 m_end;
		[SerializeField]
		float m_slack;
		[SerializeField]
		int m_steps;
		[SerializeField]
		Color m_color;
		[SerializeField]
		bool m_regen;
		[SerializeField]
		bool m_handles;
	
		static readonly Vector3[] emptyCurve = {new Vector3 (0.0f, 0.0f, 0.0f), new Vector3 (0.0f, 0.0f, 0.0f)};
		[SerializeField]
		Vector3[] points;
	
		public bool drawHandles
		{
			get => m_handles;
			set => m_handles = value;
		}
	
		public bool regenPoints
		{
			get => m_regen;
			set => m_regen = value;
		}
	
		public Vector3 start
		{
			get => m_start;
			set {
				if (value != m_start)
					m_regen = true;
				m_start = value;
			}
		}
	
		public Vector3 end
		{
			get => m_end;
			set {
				if (value != m_end)
					m_regen = true;
				m_end = value;
			}
		}
		public float slack
		{
			get => m_slack;
			set {
				if (value != m_slack)
					m_regen = true;
				m_slack = Mathf.Max(0.0f, value);
			}
		}
		public int steps
		{
			get => m_steps;
			set {
				if (value != m_steps)
					m_regen = true;
				m_steps = Mathf.Max (2, value);
			}
		}
	
		public CableCurve () {
			points = emptyCurve;
			m_start = Vector3.up;
			m_end = Vector3.up + Vector3.forward;
			m_slack = 0.5f;
			m_steps = 20;
			m_regen = true;
			m_color = Color.white;
			m_handles = true;
		}
	
		public CableCurve (CableCurve v) {
			points = v.Points ();
			m_start = v.start;
			m_end = v.end;
			m_slack = v.slack;
			m_steps = v.steps;
			m_regen = v.regenPoints;
			m_handles = v.drawHandles;
		}
	
		public Color[] Colors () {
			Color[] cols = new Color[m_steps];
			for (int c = 0; c < m_steps; c++) {
				cols[c] = m_color;
			}
			return cols;
		}
	
		public Vector3[] Points ()
		{
			if (!m_regen)
				return points;
	
			if (m_steps < 2)
				return emptyCurve;
	
			float lineDist = Vector3.Distance (m_end, m_start);
			float lineDistH = Vector3.Distance (new Vector3(m_end.x, m_start.y, m_end.z), m_start);
			float l = lineDist + Mathf.Max(0.0001f, m_slack);
			const float r = 0.0f;
			float s = m_start.y;
			float u = lineDistH;
			float v = end.y;
	
			if (u-r == 0.0f)
				return emptyCurve;
	
			float ztarget = Mathf.Sqrt(Mathf.Pow(l, 2.0f) - Mathf.Pow(v-s, 2.0f)) / (u-r);
	
			int loops = 30;
			int iterationCount = 0;
			int maxIterations = loops * 10; // For safety.
			bool found = false;
	
			float z = 0.0f;
			float zstep = 100.0f;
			for (int i = 0; i < loops; i++) {
				for (int j = 0; j < 10; j++) {
					iterationCount++;
					float ztest = z + zstep;
					float ztesttarget = (float)Math.Sinh(ztest)/ztest;
	
					if (float.IsInfinity (ztesttarget))
						continue;
	
					if (ztesttarget == ztarget) {
						found = true;
						z = ztest;
						break;
					}
					if (ztesttarget > ztarget)
						break;
					z = ztest;

					if (iterationCount > maxIterations) {
						found = true;
						break;
					}
				}
	
				if (found)
					break;
				
				zstep *= 0.1f;
			}
	
			float a = (u-r)/2.0f/z;
			float p = (r+u-a*Mathf.Log((l+v-s)/(l-v+s)))/2.0f;
			float q = (v+s-l*(float)Math.Cosh(z)/(float)Math.Sinh(z))/2.0f;
	
			if(points == null || points.Length != m_steps)
				points = new Vector3[m_steps];
			float stepsf = m_steps-1;
			for (int i = 0; i < m_steps; i++) {
				float stepf = i / stepsf;
				Vector3 pos = Vector3.zero;
				pos.x = Mathf.Lerp(start.x, end.x, stepf);
				pos.z = Mathf.Lerp(start.z, end.z, stepf);
				pos.y = a * (float)Math.Cosh(((stepf*lineDistH)-p)/a)+q;
				points[i] = pos;
			}
	
			m_regen = false;
			return points;
		}
	}
}

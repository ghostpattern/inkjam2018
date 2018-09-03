using System.Collections;
using UnityEngine;

public class InkVisualLink : MonoBehaviour
{
    public string Key;
    [SerializeField]
    private Animator _animator;
    [SerializeField]
    private MeshRenderer _meshRenderer;

    // Use this for initialization
    void Start ()
    {
        if(_animator == null)
            _animator = GetComponent<Animator>();

        if(_meshRenderer == null)
            _meshRenderer = GetComponent<MeshRenderer>();
    }

    public void Animate(string triggerParameter, float delayTime = 0.0f)
    {
        StartCoroutine(AnimateCoroutine(triggerParameter, delayTime));
    }

    private IEnumerator AnimateCoroutine(string triggerParameter, float delayTime)
    {
        if(delayTime > 0)
        {
            yield return new WaitForSeconds(delayTime);
        }

        if(_animator != null)
        {
            _animator.SetTrigger(triggerParameter);
        }
        else
        {
            Debug.LogWarningFormat("Attempted to play animation {0} on {1} - but object doesn't have an animator component", triggerParameter, Key);
        }
    }

    public void Show(float fadeTime)
    {
        if(_meshRenderer != null)
        {
            _meshRenderer.enabled = true;
            
            if(fadeTime > 0)
            {
                LeanTween.value(_meshRenderer.gameObject, v =>
                {
                    Color c = _meshRenderer.material.color;
                    c.a = v;
                    _meshRenderer.material.color = c;
                }, 0.0f, 1.0f, fadeTime).tweenType = LeanTweenType.easeInOutCubic;
            }
            else
            {
                Color c = _meshRenderer.material.color;
                c.a = 1.0f;
                _meshRenderer.material.color = c;
            }
        }
        else
        {
            Debug.LogWarningFormat("Attempted to show {0} - but object doesn't have an animator component", Key);
        }
    }

    public void Hide(float fadeTime)
    {
        if(_meshRenderer != null)
        {
            if(fadeTime > 0)
            {
                LeanTween.value(_meshRenderer.gameObject, v =>
                {
                    Color c = _meshRenderer.material.color;
                    c.a = v;
                    _meshRenderer.material.color = c;
                }, 1.0f, 0.0f, fadeTime).tweenType = LeanTweenType.easeInOutCubic;
            }
            else
            {
                _meshRenderer.enabled = false;
            }
        }
        else
        {
            Debug.LogWarningFormat("Attempted to show {0} - but object doesn't have an animator component", Key);
        }
    }
}
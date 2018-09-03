using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class TitleScreen : MonoBehaviour {

    public Image Fader;
    public AudioSource Audio;
    private bool _fadedIn = false;
    private bool _continuing = false;
    // Use this for initialization
    void Start ()
    {
        Audio = GetComponentInChildren<AudioSource>();
        Fader.gameObject.SetActive(true);
        Image uiImage = Fader.GetComponent<Image>();
        uiImage.color = Color.black;
        FadeIn(1.0f);
    }
	
	// Update is called once per frame
	void Update () {
	    if(_fadedIn && !_continuing)
	    {
	        if(Input.GetMouseButtonDown(0))
            {
                _continuing = true;
                FadeOut(1.0f);
            }
	    }
    }
    public void FadeIn(float time)
    {
        if(time > 0)
        {
            LTDescr tween = LeanTween.alpha(Fader.rectTransform, 0.0f, time);
            tween.tweenType = LeanTweenType.easeInOutQuad;
            tween.onComplete = () =>
            {
                Fader.gameObject.SetActive(false);
                _fadedIn = true;
            };

            LeanTween.value(Audio.gameObject, val => Audio.volume = val, 0.0f, 1.0f, time);
        }
        else
        {
            Image uiImage = Fader.GetComponent<Image>();
            Color c = uiImage.color;
            c.a = 0.0f;
            uiImage.color = c;
            Fader.gameObject.SetActive(false);
        }
    }

    public void FadeOut(float time)
    {
        Fader.gameObject.SetActive(true);
        if(time > 0)
        {
            LTDescr tween = LeanTween.alpha(Fader.rectTransform, 1.0f, time);
            tween.tweenType = LeanTweenType.easeInOutQuad;
            tween.onComplete = () => SceneManager.LoadScene("Master Scene");

            LeanTween.value(Audio.gameObject, val => Audio.volume = val, 1.0f, 0.0f, time);
        }
        else
        {
            Image uiImage = Fader.GetComponent<Image>();
            Color c = uiImage.color;
            c.a = 1.0f;
            uiImage.color = c;
        }
    }
}

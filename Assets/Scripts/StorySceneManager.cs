using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class StorySceneManager : MonoBehaviourSingleton<StorySceneManager>
{
    public string[] SceneList;
    public Image Fader;

    private bool _transitioning;
    private string _currentSceneName = null;

    public void FadeIn(float time)
    {
        if(time > 0)
        {
            LTDescr tween = LeanTween.alpha(Fader.rectTransform, 0.0f, time);
            tween.tweenType = LeanTweenType.easeInOutQuad;
            tween.onComplete = () => Fader.gameObject.SetActive(false);
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
        }
        else
        {
            Image uiImage = Fader.GetComponent<Image>();
            Color c = uiImage.color;
            c.a = 1.0f;
            uiImage.color = c;
        }
    }

    public void LoadScene(int sceneNumber, float delay)
    {
        int sceneIndex = sceneNumber - 1;
        
        StartCoroutine(LoadSceneAfterDelay(SceneList[sceneIndex], delay));
    }

    protected override bool DestroyOnLoad {
        get { return true; }
    }
    protected override void InitSingletonInstance()
    {

    }

    protected override void DestroySingletonInstance()
    {
    }

    void Start()
    {
        Fader.gameObject.SetActive(true);
        Image uiImage = Fader.GetComponent<Image>();
        uiImage.color = Color.black;

        // LeanTween.value(SceneSource.gameObject, v => SceneSource.volume = v, 0.0f, 1.0f, 5.0f);
    }

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.R) && (Input.GetKey(KeyCode.LeftControl) || Input.GetKey(KeyCode.RightControl)))
        {
            SceneManager.LoadScene("title");
        }
    }

    public IEnumerator LoadSceneAfterDelay(string sceneName, float delay)
    {
        yield return new WaitForSeconds(delay);
        if(string.IsNullOrEmpty(_currentSceneName) == false)
        {
            SceneManager.UnloadSceneAsync(_currentSceneName);
        }

        SceneManager.LoadScene(sceneName, LoadSceneMode.Additive);
        _currentSceneName = sceneName;
    }
}

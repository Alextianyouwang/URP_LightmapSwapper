using UnityEngine;

public class SwingBackandforth : MonoBehaviour
{
    private Vector3 startPos;
    public float offset;
    void Start()
    {
        startPos = transform.position;
    }
    
    void Update()
    {
        transform.position = startPos + transform.forward * Mathf.Sin(Time.time + offset) * 0.5f;
    }
}

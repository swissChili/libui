#include "../../ui.h"
#include <string.h>
#include <stdlib.h>

int onClosing(uiWindow *w, void *data)
{
	uiQuit();
	return 1;
}

int main(void)
{
	uiInitOptions o;
	uiWindow *w;
	uiWebView *s;

	memset(&o, 0, sizeof (uiInitOptions));
	if (uiInit(&o) != NULL)
		abort();

	w = uiNewWindow("Scrolling", 320, 240, 0);
	s = uiNewWebView("");

	uiWindowOnClosing(w, onClosing, NULL);
	uiWindowSetChild(w, uiControl(s));
	uiControlShow(uiControl(w));
	uiMain();
	return 0;
}

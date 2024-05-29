// 13 august 2015
#import "uipriv_darwin.h"

#import <WebKit/WebKit.h>

struct uiWebView {
	uiDarwinControl c;
	WebView *web;
	void (*onClicked)(uiWebView *, void *);
	void *onClickedData;
};


uiDarwinControlAllDefaultsExceptDestroy(uiWebView, web)

static void uiWebViewDestroy(uiControl *c)
{
	uiWebView *b = uiWebView(c);

	[b->web release];
	uiFreeControl(uiControl(b));
}

char *uiWebViewText(uiWebView *b)
{
	return "";
}

void uiWebViewSetText(uiWebView *b, const char *text)
{
	// [b->button setTitle:uiprivToNSString(text)];
}

void uiWebViewOnClicked(uiWebView *b, void (*f)(uiWebView *, void *), void *data)
{
	// b->onClicked = f;
	// b->onClickedData = data;
}

static void defaultOnClicked(uiWebView *b, void *data)
{
	// do nothing
}

uiWebView *uiNewWebView(const char *text)
{
	uiWebView *b;

	uiDarwinNewControl(uiWebView, b);

	b->web = [[WebView alloc] initWithFrame:NSZeroRect frameName:@"_self" groupName:@"libui"];
	[[b->web mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];

	return b;
}

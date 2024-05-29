// 27 may 2016
#include "uipriv_darwin.h"

// see http://stackoverflow.com/questions/37979445/how-do-i-properly-set-up-a-scrolling-nstableview-using-auto-layout-what-ive-tr for why we don't use auto layout
// TODO do the same with uiScrollView and uiTab?

struct uiprivScrollViewData {
	BOOL hscroll;
	BOOL vscroll;
};

NSScrollView *uiprivMkScrollView(uiprivScrollViewCreateParams *p, uiprivScrollViewData **dout)
{
	NSScrollView *sv;
	NSBorderType border;
	uiprivScrollViewData *d;

	sv = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
	if (p->BackgroundColor != nil)
		[sv setBackgroundColor:p->BackgroundColor];
	[sv setDrawsBackground:p->DrawsBackground];
	border = NSNoBorder;
	if (p->Bordered)
		border = NSBezelBorder;
	// document view seems to set the cursor properly
	[sv setBorderType:border];
	[sv setAutohidesScrollers:NO];
	[sv setHasHorizontalRuler:NO];
	[sv setHasVerticalRuler:NO];
	[sv setRulersVisible:NO];
	[sv setScrollerKnobStyle:NSScrollerKnobStyleDefault];
	// the scroller style is documented as being set by default for us
	// LONGTERM verify line and page for programmatically created NSTableView
	[sv setScrollsDynamically:YES];
	[sv setFindBarPosition:NSScrollViewFindBarPositionAboveContent];
	[sv setUsesPredominantAxisScrolling:NO];
	[sv setHorizontalScrollElasticity:NSScrollElasticityAutomatic];
	[sv setVerticalScrollElasticity:NSScrollElasticityAutomatic];
	[sv setAllowsMagnification:NO];

    if (p->DocumentView != nil)
    	[sv setDocumentView:p->DocumentView];

    d = uiprivNew(uiprivScrollViewData);
	uiprivScrollViewSetScrolling(sv, d, p->HScroll, p->VScroll);

	*dout = d;
	return sv;
}

// based on http://blog.bjhomer.com/2014/08/nsscrollview-and-autolayout.html because (as pointed out there) Apple's official guide is really only for iOS
void uiprivScrollViewSetScrolling(NSScrollView *sv, uiprivScrollViewData *d, BOOL hscroll, BOOL vscroll)
{
	d->hscroll = hscroll;
	[sv setHasHorizontalScroller:d->hscroll];
	d->vscroll = vscroll;
	[sv setHasVerticalScroller:d->vscroll];
}

void uiprivScrollViewFreeData(NSScrollView *sv, uiprivScrollViewData *d)
{
	uiprivFree(d);
}

struct uiScrollView {
    uiDarwinControl c;
    NSScrollView *sv;
    uiprivScrollViewData *d;
    uiControl *child;
};

static void uiScrollViewDestroy(uiControl *c)
{
    uiScrollView *g = uiScrollView(c);

    if (g->child != NULL) {
        uiControlSetParent(g->child, NULL);
        uiDarwinControlSetSuperview(uiDarwinControl(g->child), nil);
        uiControlDestroy(g->child);
    }
    [g->sv release];
    uiFreeControl(uiControl(g));
}

uiDarwinControlAllDefaultsExceptDestroy(uiScrollView, sv)

void uiScrollViewSetChild(uiScrollView *g, uiControl *child)
{
    if (g->child != NULL) {
        uiControlSetParent(g->child, NULL);
        uiDarwinControlSetSuperview(uiDarwinControl(g->child), nil);
    }
    g->child = child;

    if (g->child != NULL) {
        NSView *childView = (NSView *) uiControlHandle(g->child);
        uiControlSetParent(g->child, uiControl(g));
        uiDarwinControlSetSuperview(uiDarwinControl(g->child), [g->sv contentView]);
        uiDarwinControlSyncEnableState(uiDarwinControl(g->child), uiControlEnabledToUser(uiControl(g)));
    }
}


int uiScrollViewMargined(uiScrollView *v)
{
    return 0;
}
void uiScrollViewSetMargined(uiScrollView *v, int margined)
{}

uiScrollView *uiNewScrollView(void)
{
    uiScrollView *g;

    uiDarwinNewControl(uiScrollView, g);

    uiprivScrollViewCreateParams params = {
        nil,
        nil,
        NO,
        YES,
        YES,
        YES
    };

    g->sv = uiprivMkScrollView(&params, &g->d);

    return g;
}

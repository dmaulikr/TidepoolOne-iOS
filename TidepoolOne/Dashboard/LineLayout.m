#import "LineLayout.h"


#define ITEM_SIZE 60.0

@implementation LineLayout

#define ACTIVE_DISTANCE 160
#define ACTIVE_DISTANCE_IPHONE_4 160
#define ZOOM_FACTOR 0.75

-(id)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(160, 0.0, 160, 0.0);
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                // Load resources for iOS 6.1 or earlier
                CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
                if (ABS(distance) < ACTIVE_DISTANCE) {
                    CGFloat zoom = 1 + ZOOM_FACTOR*(1 - ABS(normalizedDistance));
                }
            } else {
                //Default in iOS 7 is cool
                CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
                if (ABS(distance) < ACTIVE_DISTANCE) {
                    CGFloat zoom = 1 + ZOOM_FACTOR*(1 - ABS(normalizedDistance));
                    attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                    attributes.zIndex = 1;
                }
            }
        }
    }
    return array;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
package app.organicmaps.widget.placepage.sections;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import app.organicmaps.R;
import app.organicmaps.sdk.Framework;
import app.organicmaps.sdk.bookmarks.data.MapObject;
import app.organicmaps.sdk.bookmarks.data.Metadata;
import app.organicmaps.util.Utils;
import app.organicmaps.widget.placepage.PlacePageUtils;
import app.organicmaps.widget.placepage.PlacePageViewModel;
import com.google.android.material.textview.MaterialTextView;
import java.util.ArrayList;
import java.util.List;

public class PlacePageLinksFragment extends Fragment implements Observer<MapObject>
{
  private static final String TAG = PlacePageLinksFragment.class.getSimpleName();

  private View mFrame;
  private View mFacebookPage;
  private View mInstagramPage;
  private View mTwitterPage;
  private View mFediversePage;
  private View mBlueskyPage;
  private View mVkPage;
  private View mLinePage;

  private View mWebsite;
  private View mWebsiteMenu;
  private View mEmail;
  private MaterialTextView mTvEmail;
  private View mWikimedia;

  private View mPanoramax;

  private PlacePageViewModel mViewModel;
  private MapObject mMapObject;

  private static void refreshMetadataOrHide(@Nullable String metadata, @NonNull View metaLayout,
                                            @NonNull MaterialTextView metaTv)
  {
    if (!TextUtils.isEmpty(metadata))
    {
      metaLayout.setVisibility(VISIBLE);
      metaTv.setText(metadata);
    }
    else
      metaLayout.setVisibility(GONE);
  }

  @NonNull
  private String getLink(@NonNull Metadata.MetadataType type)
  {
    return switch (type)
    {
      case FMD_WEBSITE -> mMapObject.getWebsiteUrl(false /* strip */, Metadata.MetadataType.FMD_WEBSITE);
      case FMD_WEBSITE_MENU -> mMapObject.getWebsiteUrl(false /* strip */, Metadata.MetadataType.FMD_WEBSITE_MENU);
      case FMD_CONTACT_FACEBOOK, FMD_CONTACT_INSTAGRAM, FMD_CONTACT_TWITTER, FMD_CONTACT_FEDIVERSE, FMD_CONTACT_BLUESKY,
          FMD_CONTACT_VK, FMD_CONTACT_LINE, FMD_PANORAMAX ->
      {
        if (TextUtils.isEmpty(mMapObject.getMetadata(type)))
          yield "";
        yield Framework.nativeGetPoiContactUrl(type.toInt());
      }
      default -> mMapObject.getMetadata(type);
    };
  }

  @Nullable
  @Override
  public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                           @Nullable Bundle savedInstanceState)
  {
    mViewModel = new ViewModelProvider(requireActivity()).get(PlacePageViewModel.class);
    return inflater.inflate(R.layout.place_page_links_fragment, container, false);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState)
  {
    super.onViewCreated(view, savedInstanceState);
    mFrame = view;

    mWebsite = mFrame.findViewById(R.id.ll__place_website);
    mWebsite.setVisibility(GONE);

    mWebsiteMenu = mFrame.findViewById(R.id.ll__place_website_menu);
    mWebsiteMenu.setVisibility(GONE);

    mEmail = mFrame.findViewById(R.id.ll__place_email);
    mTvEmail = mFrame.findViewById(R.id.tv__place_email);
    mEmail.setOnClickListener(v -> {
      final String email = mMapObject.getMetadata(Metadata.MetadataType.FMD_EMAIL);
      if (!TextUtils.isEmpty(email))
        Utils.sendTo(requireContext(), email);
    });
    mEmail.setOnLongClickListener((v) -> copyUrl(mEmail, Metadata.MetadataType.FMD_EMAIL));

    mWikimedia = mFrame.findViewById(R.id.ll__place_wikimedia);
    mWikimedia.setVisibility(GONE);

    mFacebookPage = mFrame.findViewById(R.id.ll__place_facebook);
    mFacebookPage.setVisibility(GONE);

    mInstagramPage = mFrame.findViewById(R.id.ll__place_instagram);
    mInstagramPage.setVisibility(GONE);

    mFediversePage = mFrame.findViewById(R.id.ll__place_fediverse);
    mFediversePage.setVisibility(GONE);

    mBlueskyPage = mFrame.findViewById(R.id.ll__place_bluesky);
    mBlueskyPage.setVisibility(GONE);

    mTwitterPage = mFrame.findViewById(R.id.ll__place_twitter);
    mTwitterPage.setVisibility(GONE);

    mVkPage = mFrame.findViewById(R.id.ll__place_vk);
    mVkPage.setVisibility(GONE);

    mLinePage = mFrame.findViewById(R.id.ll__place_line);
    mLinePage.setVisibility(GONE);

    mPanoramax = mFrame.findViewById(R.id.ll__place_panoramax);
    mPanoramax.setVisibility(GONE);
  }

  private void openUrl(Metadata.MetadataType type)
  {
    final String url = getLink(type);
    if (!TextUtils.isEmpty(url))
      Utils.openUrl(requireContext(), url);
  }

  private boolean copyUrl(View view, Metadata.MetadataType type)
  {
    final String url = getLink(type);
    if (TextUtils.isEmpty(url))
      return false;
    final List<String> items = new ArrayList<>();
    items.add(url);

    final String title = switch (type)
    {
      case FMD_WEBSITE -> mMapObject.getWebsiteUrl(false /* strip */, Metadata.MetadataType.FMD_WEBSITE);
      case FMD_WEBSITE_MENU -> mMapObject.getWebsiteUrl(false /* strip */, Metadata.MetadataType.FMD_WEBSITE_MENU);
      case FMD_PANORAMAX -> null; // Don't add raw ID to list, as it's useless for users.
      default -> mMapObject.getMetadata(type);
    };
    // Add user names for social media if available
    if (!TextUtils.isEmpty(title) && !title.equals(url) && !title.contains("/"))
      items.add(title);

    if (items.size() == 1)
      PlacePageUtils.copyToClipboard(requireContext(), mFrame, items.get(0));
    else
      PlacePageUtils.showCopyPopup(requireContext(), view, items);
    return true;
  }

  private void refreshLinks()
  {
    refreshMetadataOrHide(mMapObject.getMetadata(Metadata.MetadataType.FMD_EMAIL), mEmail, mTvEmail);
  }

  @Override
  public void onStart()
  {
    super.onStart();
    mViewModel.getMapObject().observe(requireActivity(), this);
  }

  @Override
  public void onStop()
  {
    super.onStop();
    mViewModel.getMapObject().removeObserver(this);
  }

  @Override
  public void onChanged(@Nullable MapObject mapObject)
  {
    if (mapObject != null)
    {
      mMapObject = mapObject;
      refreshLinks();
    }
  }
}

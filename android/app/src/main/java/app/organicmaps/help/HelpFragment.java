package app.organicmaps.help;

import android.content.res.Configuration;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.ViewCompat;
import app.organicmaps.BuildConfig;
import app.organicmaps.R;
import app.organicmaps.base.BaseMwmFragment;
import app.organicmaps.sdk.Framework;
import app.organicmaps.sdk.util.DateUtils;
import app.organicmaps.util.Graphics;
import app.organicmaps.util.SharingUtils;
import app.organicmaps.util.Utils;
import app.organicmaps.util.WindowInsetUtils.ScrollableContentInsetsListener;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.textview.MaterialTextView;

public class HelpFragment extends BaseMwmFragment implements View.OnClickListener
{
  private String mDonateUrl;
  private ActivityResultLauncher<SharingUtils.SharingIntent> shareLauncher;

  private void setupItem(@IdRes int id, boolean tint, @NonNull View frame)
  {
    final TextView view = frame.findViewById(id);
    view.setOnClickListener(this);
    if (tint)
      Graphics.tint(view);
  }

  @Override
  public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState)
  {
    mDonateUrl = Utils.getDonateUrl(requireContext());
    View root = inflater.inflate(R.layout.about, container, false);

    ((MaterialTextView) root.findViewById(R.id.version)).setText(BuildConfig.VERSION_NAME);

    final boolean isLandscape = getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE;

    final String dataVersion = DateUtils.getShortDateFormatter().format(Framework.getDataVersion());
    final MaterialTextView osmPresentationView = root.findViewById(R.id.osm_presentation);
    if (osmPresentationView != null)
      osmPresentationView.setText(getString(R.string.osm_presentation, dataVersion));

    setupItem(R.id.faq, true, root);
    setupItem(R.id.email, true, root);
    setupItem(R.id.report, isLandscape, root);
    setupItem(R.id.copyright, false, root);

    final int[] webOnlyItems = {R.id.news, R.id.web, R.id.code_repo, R.id.mastodon, R.id.matrix,
        R.id.lemmy, R.id.bluesky, R.id.pixelfed, R.id.openstreetmap, R.id.support_us,
        R.id.donate, R.id.rate, R.id.term_of_use_link, R.id.privacy_policy};
    for (int id : webOnlyItems)
    {
      View item = root.findViewById(id);
      if (item != null)
        item.setVisibility(View.GONE);
    }

    shareLauncher = SharingUtils.RegisterLauncher(this);

    ViewCompat.setOnApplyWindowInsetsListener(root, new ScrollableContentInsetsListener(root));

    return root;
  }

  @Override
  public void onClick(View v)
  {
    final int id = v.getId();
    if (id == R.id.email)
      Utils.sendTo(requireContext(), BuildConfig.SUPPORT_MAIL, getString(R.string.project_name));
    else if (id == R.id.faq)
      ((HelpActivity) requireActivity()).stackFragment(FaqFragment.class, getString(R.string.faq), null);
    else if (id == R.id.report)
      Utils.sendBugReport(shareLauncher, requireActivity(), "", "");
    else if (id == R.id.copyright)
      ((HelpActivity) requireActivity()).stackFragment(CopyrightFragment.class, getString(R.string.copyright), null);
  }
}

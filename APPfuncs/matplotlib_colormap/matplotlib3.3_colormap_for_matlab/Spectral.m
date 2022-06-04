function map = Spectral(N)
% MatPlotLib 3.3 配色方案
% 输入:
% N   -  定义colormap长度的整数（N>=0）；若为空，则为当前图窗colormap长度
%
% 输出:
% map -  Nx3的RGB颜色矩阵
%
% Copyright  2020   Akun
% https://zhuanlan.zhihu.com/c_1074615528869531648

if nargin<1 || isempty(N)
	N = size(get(gcf,'colormap'),1);
else
	assert(isscalar(N)&&isreal(N),'First argument must be a real numeric scalar.')
end

C = [0.619607843137255,0.00392156862745098,0.258823529411765;0.627450980392157,0.0117647058823529,0.258823529411765;0.635294117647059,0.0196078431372549,0.262745098039216;0.643137254901961,0.0313725490196078,0.262745098039216;0.654901960784314,0.0431372549019608,0.266666666666667;0.658823529411765,0.0470588235294118,0.266666666666667;0.678431372549020,0.0666666666666667,0.270588235294118;0.686274509803922,0.0784313725490196,0.274509803921569;0.694117647058824,0.0862745098039216,0.274509803921569;0.701960784313725,0.0941176470588235,0.278431372549020;0.709803921568628,0.105882352941176,0.278431372549020;0.717647058823529,0.113725490196078,0.282352941176471;0.733333333333333,0.129411764705882,0.286274509803922;0.737254901960784,0.133333333333333,0.286274509803922;0.752941176470588,0.152941176470588,0.290196078431373;0.760784313725490,0.160784313725490,0.290196078431373;0.768627450980392,0.172549019607843,0.294117647058824;0.776470588235294,0.180392156862745,0.294117647058824;0.788235294117647,0.188235294117647,0.298039215686275;0.796078431372549,0.200000000000000,0.298039215686275;0.811764705882353,0.219607843137255,0.301960784313725;0.815686274509804,0.223529411764706,0.305882352941177;0.827450980392157,0.235294117647059,0.305882352941177;0.835294117647059,0.243137254901961,0.305882352941177;0.839215686274510,0.250980392156863,0.305882352941177;0.847058823529412,0.258823529411765,0.301960784313725;0.850980392156863,0.270588235294118,0.301960784313725;0.854901960784314,0.274509803921569,0.298039215686275;0.862745098039216,0.286274509803922,0.294117647058824;0.870588235294118,0.294117647058824,0.294117647058824;0.874509803921569,0.301960784313725,0.294117647058824;0.878431372549020,0.309803921568627,0.290196078431373;0.882352941176471,0.317647058823529,0.290196078431373;0.886274509803922,0.325490196078431,0.286274509803922;0.898039215686275,0.337254901960784,0.282352941176471;0.898039215686275,0.341176470588235,0.282352941176471;0.905882352941177,0.352941176470588,0.278431372549020;0.913725490196078,0.360784313725490,0.278431372549020;0.917647058823529,0.368627450980392,0.274509803921569;0.921568627450980,0.376470588235294,0.274509803921569;0.925490196078431,0.380392156862745,0.270588235294118;0.929411764705882,0.388235294117647,0.270588235294118;0.941176470588235,0.403921568627451,0.266666666666667;0.945098039215686,0.411764705882353,0.262745098039216;0.949019607843137,0.419607843137255,0.262745098039216;0.956862745098039,0.427450980392157,0.262745098039216;0.956862745098039,0.435294117647059,0.266666666666667;0.956862745098039,0.447058823529412,0.270588235294118;0.960784313725490,0.458823529411765,0.274509803921569;0.960784313725490,0.466666666666667,0.278431372549020;0.964705882352941,0.486274509803922,0.290196078431373;0.964705882352941,0.494117647058824,0.294117647058824;0.964705882352941,0.505882352941176,0.298039215686275;0.968627450980392,0.513725490196078,0.301960784313725;0.968627450980392,0.525490196078431,0.305882352941177;0.968627450980392,0.537254901960784,0.309803921568627;0.972549019607843,0.556862745098039,0.321568627450980;0.972549019607843,0.560784313725490,0.321568627450980;0.976470588235294,0.576470588235294,0.329411764705882;0.976470588235294,0.584313725490196,0.333333333333333;0.980392156862745,0.596078431372549,0.337254901960784;0.980392156862745,0.603921568627451,0.345098039215686;0.980392156862745,0.615686274509804,0.349019607843137;0.984313725490196,0.623529411764706,0.352941176470588;0.984313725490196,0.647058823529412,0.360784313725490;0.988235294117647,0.654901960784314,0.368627450980392;0.988235294117647,0.666666666666667,0.372549019607843;0.988235294117647,0.674509803921569,0.376470588235294;0.992156862745098,0.682352941176471,0.380392156862745;0.992156862745098,0.690196078431373,0.388235294117647;0.992156862745098,0.701960784313725,0.400000000000000;0.992156862745098,0.705882352941177,0.400000000000000;0.992156862745098,0.721568627450980,0.415686274509804;0.992156862745098,0.729411764705882,0.419607843137255;0.992156862745098,0.737254901960784,0.427450980392157;0.992156862745098,0.745098039215686,0.431372549019608;0.992156862745098,0.752941176470588,0.439215686274510;0.992156862745098,0.760784313725490,0.447058823529412;0.992156862745098,0.776470588235294,0.458823529411765;0.992156862745098,0.780392156862745,0.462745098039216;0.992156862745098,0.792156862745098,0.470588235294118;0.992156862745098,0.800000000000000,0.478431372549020;0.992156862745098,0.807843137254902,0.486274509803922;0.992156862745098,0.815686274509804,0.490196078431373;0.992156862745098,0.823529411764706,0.498039215686275;0.992156862745098,0.831372549019608,0.505882352941176;0.992156862745098,0.847058823529412,0.517647058823530;0.992156862745098,0.854901960784314,0.525490196078431;0.992156862745098,0.862745098039216,0.529411764705882;0.992156862745098,0.870588235294118,0.537254901960784;0.996078431372549,0.878431372549020,0.545098039215686;0.996078431372549,0.882352941176471,0.552941176470588;0.996078431372549,0.890196078431373,0.564705882352941;0.996078431372549,0.890196078431373,0.568627450980392;0.996078431372549,0.901960784313726,0.584313725490196;0.996078431372549,0.905882352941177,0.592156862745098;0.996078431372549,0.909803921568627,0.600000000000000;0.996078431372549,0.913725490196078,0.611764705882353;0.996078431372549,0.917647058823529,0.615686274509804;0.996078431372549,0.925490196078431,0.623529411764706;0.996078431372549,0.933333333333333,0.639215686274510;0.996078431372549,0.937254901960784,0.643137254901961;0.996078431372549,0.945098039215686,0.654901960784314;0.996078431372549,0.949019607843137,0.662745098039216;0.996078431372549,0.952941176470588,0.670588235294118;0.996078431372549,0.956862745098039,0.678431372549020;0.996078431372549,0.964705882352941,0.690196078431373;0.996078431372549,0.968627450980392,0.694117647058824;0.996078431372549,0.976470588235294,0.709803921568628;0.996078431372549,0.980392156862745,0.717647058823529;0.996078431372549,0.984313725490196,0.725490196078431;0.996078431372549,0.992156862745098,0.733333333333333;0.996078431372549,0.996078431372549,0.741176470588235;0.996078431372549,0.996078431372549,0.745098039215686;0.988235294117647,0.996078431372549,0.733333333333333;0.988235294117647,0.996078431372549,0.733333333333333;0.980392156862745,0.992156862745098,0.721568627450980;0.976470588235294,0.988235294117647,0.713725490196078;0.972549019607843,0.988235294117647,0.709803921568628;0.968627450980392,0.988235294117647,0.701960784313725;0.964705882352941,0.984313725490196,0.698039215686275;0.960784313725490,0.984313725490196,0.690196078431373;0.952941176470588,0.980392156862745,0.678431372549020;0.949019607843137,0.980392156862745,0.674509803921569;0.945098039215686,0.976470588235294,0.666666666666667;0.941176470588235,0.976470588235294,0.658823529411765;0.937254901960784,0.972549019607843,0.654901960784314;0.929411764705882,0.972549019607843,0.643137254901961;0.929411764705882,0.972549019607843,0.639215686274510;0.925490196078431,0.968627450980392,0.635294117647059;0.917647058823529,0.964705882352941,0.623529411764706;0.913725490196078,0.964705882352941,0.619607843137255;0.909803921568627,0.964705882352941,0.611764705882353;0.905882352941177,0.960784313725490,0.607843137254902;0.901960784313726,0.960784313725490,0.600000000000000;0.901960784313726,0.960784313725490,0.596078431372549;0.882352941176471,0.952941176470588,0.596078431372549;0.878431372549020,0.952941176470588,0.596078431372549;0.862745098039216,0.945098039215686,0.600000000000000;0.854901960784314,0.941176470588235,0.603921568627451;0.847058823529412,0.937254901960784,0.603921568627451;0.831372549019608,0.929411764705882,0.607843137254902;0.827450980392157,0.929411764705882,0.607843137254902;0.819607843137255,0.925490196078431,0.611764705882353;0.800000000000000,0.917647058823529,0.615686274509804;0.792156862745098,0.913725490196078,0.615686274509804;0.780392156862745,0.909803921568627,0.619607843137255;0.772549019607843,0.905882352941177,0.619607843137255;0.764705882352941,0.901960784313726,0.623529411764706;0.745098039215686,0.898039215686275,0.627450980392157;0.741176470588235,0.898039215686275,0.627450980392157;0.737254901960784,0.894117647058824,0.627450980392157;0.717647058823529,0.886274509803922,0.631372549019608;0.709803921568628,0.882352941176471,0.631372549019608;0.701960784313725,0.878431372549020,0.635294117647059;0.690196078431373,0.874509803921569,0.635294117647059;0.682352941176471,0.870588235294118,0.639215686274510;0.674509803921569,0.866666666666667,0.639215686274510;0.650980392156863,0.858823529411765,0.643137254901961;0.647058823529412,0.858823529411765,0.643137254901961;0.631372549019608,0.850980392156863,0.643137254901961;0.619607843137255,0.847058823529412,0.643137254901961;0.611764705882353,0.843137254901961,0.643137254901961;0.592156862745098,0.835294117647059,0.643137254901961;0.588235294117647,0.835294117647059,0.643137254901961;0.580392156862745,0.831372549019608,0.643137254901961;0.556862745098039,0.819607843137255,0.643137254901961;0.545098039215686,0.815686274509804,0.643137254901961;0.537254901960784,0.811764705882353,0.643137254901961;0.525490196078431,0.807843137254902,0.643137254901961;0.513725490196078,0.803921568627451,0.643137254901961;0.494117647058824,0.796078431372549,0.643137254901961;0.486274509803922,0.792156862745098,0.643137254901961;0.482352941176471,0.792156862745098,0.643137254901961;0.462745098039216,0.784313725490196,0.643137254901961;0.450980392156863,0.780392156862745,0.643137254901961;0.439215686274510,0.776470588235294,0.643137254901961;0.427450980392157,0.772549019607843,0.643137254901961;0.419607843137255,0.768627450980392,0.643137254901961;0.400000000000000,0.760784313725490,0.647058823529412;0.388235294117647,0.749019607843137,0.647058823529412;0.384313725490196,0.745098039215686,0.650980392156863;0.372549019607843,0.733333333333333,0.654901960784314;0.364705882352941,0.721568627450980,0.658823529411765;0.356862745098039,0.713725490196078,0.662745098039216;0.345098039215686,0.701960784313725,0.670588235294118;0.341176470588235,0.694117647058824,0.670588235294118;0.333333333333333,0.686274509803922,0.674509803921569;0.317647058823529,0.670588235294118,0.682352941176471;0.309803921568627,0.658823529411765,0.686274509803922;0.301960784313725,0.650980392156863,0.690196078431373;0.294117647058824,0.643137254901961,0.694117647058824;0.286274509803922,0.635294117647059,0.698039215686275;0.270588235294118,0.615686274509804,0.705882352941177;0.266666666666667,0.611764705882353,0.709803921568628;0.262745098039216,0.607843137254902,0.709803921568628;0.247058823529412,0.588235294117647,0.713725490196078;0.239215686274510,0.580392156862745,0.717647058823529;0.231372549019608,0.572549019607843,0.721568627450980;0.219607843137255,0.556862745098039,0.725490196078431;0.215686274509804,0.552941176470588,0.729411764705882;0.200000000000000,0.537254901960784,0.737254901960784;0.196078431372549,0.525490196078431,0.737254901960784;0.200000000000000,0.521568627450980,0.733333333333333;0.211764705882353,0.509803921568627,0.729411764705882;0.219607843137255,0.501960784313726,0.725490196078431;0.223529411764706,0.490196078431373,0.721568627450980;0.239215686274510,0.474509803921569,0.713725490196078;0.239215686274510,0.470588235294118,0.713725490196078;0.243137254901961,0.466666666666667,0.709803921568628;0.258823529411765,0.447058823529412,0.698039215686275;0.266666666666667,0.439215686274510,0.694117647058824;0.270588235294118,0.431372549019608,0.690196078431373;0.278431372549020,0.423529411764706,0.686274509803922;0.286274509803922,0.411764705882353,0.682352941176471;0.298039215686275,0.396078431372549,0.674509803921569;0.305882352941177,0.388235294117647,0.670588235294118;0.305882352941177,0.384313725490196,0.670588235294118];

num = size(C,1);
vec = linspace(0,num+1,N+2);
map = interp1(1:num,C,vec(2:end-1),'linear','extrap'); %...插值
map = max(0,min(1,map));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% 制作：阿昆            %%%
% 公众号：阿昆的科研日常 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%